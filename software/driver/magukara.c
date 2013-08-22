#include <linux/module.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/poll.h>
#include <linux/pci.h>
#include <linux/version.h>

#define	DRV_NAME	"magukara"
#define	DRV_VERSION	"0.0.1"
#define	MAGUKARA_DRIVER_NAME	DRV_NAME " Magukara driver " DRV_VERSION

#if LINUX_VERSION_CODE > KERNEL_VERSION(3,8,0)
#define	__devinit
#define	__devexit
#define	__devexit_p
#endif

static DEFINE_PCI_DEVICE_TABLE(magukara_pci_tbl) = {
	{0x3776, 0x8000, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
	{0,}
};
MODULE_DEVICE_TABLE(pci, magukara_pci_tbl);

static unsigned long *mmio_ptr, mmio_start, mmio_end, mmio_flags, mmio_len;

static int magukara_open(struct inode *inode, struct file *filp)
{
	printk("%s\n", __func__);
	/* */
	return 0;
}

static ssize_t magukara_read(struct file *filp, char __user *buf,
			   size_t count, loff_t *ppos)
{
	int copy_len;

	printk("%s\n", __func__);

	if ( count > 256 )
		copy_len = 256;
	else
		copy_len = count;

	if ( copy_to_user( buf, mmio_ptr, copy_len ) ) {
		printk( KERN_INFO "copy_to_user failed\n" );
		return -EFAULT;
	}

	return copy_len;
}

static ssize_t magukara_write(struct file *filp, const char __user *buf,
			    size_t count, loff_t *ppos)

{
	int copy_len;
	if ( count > 256 )
		copy_len = 256;
	else
		copy_len = count;
	printk("%s\n", __func__);

	if ( copy_from_user( mmio_ptr, buf, copy_len ) ) {
		printk( KERN_INFO "copy_from_user failed\n" );
		return -EFAULT;
	}

	return copy_len;
}

static int magukara_release(struct inode *inode, struct file *filp)
{
	printk("%s\n", __func__);
	return 0;
}

static unsigned int magukara_poll(struct file *filp, poll_table *wait)
{
	printk("%s\n", __func__);
	return 0;
}


static int magukara_ioctl(struct inode *inode, struct file *filp,
			unsigned int cmd, unsigned long arg)
{
	printk("%s\n", __func__);
	return  -ENOTTY;
}

static struct file_operations magukara_fops = {
	.owner		= THIS_MODULE,
	.read		= magukara_read,
	.write		= magukara_write,
	.poll		= magukara_poll,
	.compat_ioctl	= magukara_ioctl,
	.open		= magukara_open,
	.release	= magukara_release,
};

static struct miscdevice magukara_dev = {
	.minor = MISC_DYNAMIC_MINOR,
	.name = "magukara",
	.fops = &magukara_fops,
};


static int __devinit magukara_init_one (struct pci_dev *pdev,
				       const struct pci_device_id *ent)
{
	int rc;

	mmio_ptr = 0L;

	rc = pci_enable_device (pdev);
	if (rc)
		goto err_out;

	rc = pci_request_regions (pdev, DRV_NAME);
	if (rc)
		goto err_out;

#if 0
	pci_set_master (pdev);		/* set BUS Master Mode */
#endif

	mmio_start = pci_resource_start (pdev, 0);
	mmio_end   = pci_resource_end   (pdev, 0);
	mmio_flags = pci_resource_flags (pdev, 0);
	mmio_len   = pci_resource_len   (pdev, 0);

	printk( KERN_INFO "mmio_start: %X\n", (unsigned int)mmio_start );
	printk( KERN_INFO "mmio_end  : %X\n", (unsigned int)mmio_end   );
	printk( KERN_INFO "mmio_flags: %X\n", (unsigned int)mmio_flags );
	printk( KERN_INFO "mmio_len  : %X\n", (unsigned int)mmio_len   );

	mmio_ptr = ioremap(mmio_start, mmio_len);
	if (!mmio_ptr) {
		printk(KERN_ERR "cannot ioremap MMIO base\n");
		goto err_out;
	}

	/* reset board */

	return 0;

err_out:
	pci_release_regions (pdev);
	pci_disable_device (pdev);
	return -1;
}


static void __devexit magukara_remove_one (struct pci_dev *pdev)
{
	pci_disable_device (pdev);
}


static struct pci_driver magukara_pci_driver = {
	.name		= DRV_NAME,
	.id_table	= magukara_pci_tbl,
	.probe		= magukara_init_one,
	.remove		= __devexit_p(magukara_remove_one),
#ifdef CONFIG_PM
//	.suspend	= magukara_suspend,
//	.resume		= magukara_resume,
#endif /* CONFIG_PM */
};


static int __init magukara_init(void)
{
	int ret;

#ifdef MODULE
	pr_info(MAGUKARA_DRIVER_NAME "\n");
#endif

	ret = misc_register(&magukara_dev);
	if (ret) {
		printk("fail to misc_register (MISC_DYNAMIC_MINOR)\n");
		return ret;
	}
	
	printk("Succefully loaded.\n");
	return pci_register_driver(&magukara_pci_driver);
}

static void __exit magukara_cleanup(void)
{
	misc_deregister(&magukara_dev);
 	printk("Unloaded.\n"); 
}

MODULE_LICENSE("GPL");
module_init(magukara_init);
module_exit(magukara_cleanup);
