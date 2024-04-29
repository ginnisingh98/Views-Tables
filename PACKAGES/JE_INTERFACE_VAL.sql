--------------------------------------------------------
--  DDL for Package JE_INTERFACE_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_INTERFACE_VAL" AUTHID CURRENT_USER AS
/* $Header: jgjegdfs.pls 120.6 2006/08/23 07:50:02 vgadde ship $ */

PROCEDURE ap_business_rules(
      p_calling_program_name            IN    VARCHAR2,
      p_set_of_books_id                 IN    NUMBER,
      p_invoice_date                    IN    DATE,
      p_parent_table                    IN    VARCHAR2,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_inv_vendor_site_id              IN    NUMBER,
      p_inv_payment_currency_code       IN    VARCHAR2,
      p_global_attribute_category       IN    VARCHAR2,
      p_global_attribute1               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute2               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute3               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute4               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute5               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute6               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute7               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute8               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute9               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute10              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute11              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute12              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute13              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute14              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute15              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute16              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute17              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute18              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute19              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute20              IN OUT NOCOPY    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2);


PROCEDURE je_it_apxiisim_def
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2);

PROCEDURE je_es_apxiisim_modelo349
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2);


PROCEDURE je_cz_apxiisim_invoice_info
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2);

PROCEDURE je_hu_apxiisim_tax_date
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2);


PROCEDURE ar_business_rules
   (p_int_table_name                  IN VARCHAR2,
    p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_current_record_status           OUT NOCOPY VARCHAR2);


PROCEDURE je_gr_arxcudci_cust_txid
(   p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_record_status                   OUT NOCOPY VARCHAR2);


PROCEDURE je_zz_arxcudci_site_uses
(   p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_record_status                   OUT NOCOPY VARCHAR2);

END JE_INTERFACE_VAL;

 

/
