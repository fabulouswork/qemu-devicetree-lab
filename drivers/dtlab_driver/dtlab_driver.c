#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/of.h>

static int dtlab_probe(struct platform_device *pdev)
{
    dev_info(&pdev->dev,
             "Device Tree laboratory driver probed!\n");

    return 0;
}

static void dtlab_remove(struct platform_device *pdev)
{
    dev_info(&pdev->dev, "Device removed\n");
}

static const struct of_device_id dtlab_of_match[] = {
    {
        .compatible = "demo,dt-lab-device",
    },
    { }
};

MODULE_DEVICE_TABLE(of, dtlab_of_match);

static struct platform_driver dtlab_driver = {
    .probe = dtlab_probe,
    .remove = dtlab_remove,

    .driver = {
        .name = "dtlab",
        .of_match_table = dtlab_of_match,
    },
};

module_platform_driver(dtlab_driver);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Device Tree laboratory driver");