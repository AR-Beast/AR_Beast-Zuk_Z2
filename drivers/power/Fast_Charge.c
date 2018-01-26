/* Fast-Charge 
 *
 * Copyright (c) 2018,  Ayush Rathore <ayushrathore12501@gmail.com>.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 */

#include <linux/module.h>
#include <linux/Fast_Charge.h>

int FC_Switch = 1; 
int custom_current = 2200;

static ssize_t fc_switch_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
	return sprintf(buf, "%d", FC_Switch);
}

static ssize_t fc_switch_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
	int input;
	sscanf (buf, "%d", &input);
	if(input < 0 || input > 1)
	       FC_Switch = 0;
return count;
}

static ssize_t custom_current_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
	return sprintf(buf, "%d", custom_current);
}

static ssize_t custom_current_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
	int inputcurrent;
	sscanf(buf, "%d", &inputcurrent);
	if(FC_Switch == 1 && inputcurrent <= 3000 && inputcurrent >= 100)
		custom_current = inputcurrent;
	else
		custom_current = 2200;
	return count;
}

static struct kobj_attribute fc_switch_attribute =
	__ATTR(FC_Switch,
		0664,
		fc_switch_show,
		fc_switch_store);

static struct kobj_attribute custom_current_attribute =
	__ATTR(custom_current,
		0664,
		custom_current_show,
        custom_current_store);

static struct attribute *fast_charge_attrs[] =
	{
		&fc_switch_attribute.attr,
		&custom_current_attribute.attr,
		NULL,
	};
	
static struct attribute_group fast_charge_attr_group =
	{
		.attrs = fast_charge_attrs,
	};

static struct kobject *fast_charge_kobj;

int fast_charge_init(void)
{
	int out;
	
	fast_charge_kobj = kobject_create_and_add("Fast_Charge", kernel_kobj);

	if (!fast_charge_kobj) 
	{
	   return -ENOMEM;
        }

	out = sysfs_create_group(fast_charge_kobj, &fast_charge_attr_group);

	if (out) 
	{
	   kobject_put(fast_charge_kobj);
	}
	return out;
}

void fast_charge_exit(void)
{
	if (fast_charge_kobj != NULL)
	   kobject_put(fast_charge_kobj);
}

module_init(fast_charge_init);
module_exit(fast_charge_exit);
