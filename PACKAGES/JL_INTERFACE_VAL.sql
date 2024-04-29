--------------------------------------------------------
--  DDL for Package JL_INTERFACE_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_INTERFACE_VAL" AUTHID CURRENT_USER AS
/* $Header: jgjlgdfs.pls 120.4 2005/03/31 01:15:49 pla ship $ */

PROCEDURE ap_business_rules
     (p_calling_program_name            IN    VARCHAR2,
      p_set_of_books_id                 IN    NUMBER,
      p_invoice_date                    IN    DATE,
      p_parent_table                    IN    VARCHAR2,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_line_type_lookup_code           IN    VARCHAR2,
      p_global_attribute_category       IN    VARCHAR2,
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

PROCEDURE jl_ar_apxiisim_invoices_folder
  (p_parent_id                  IN    NUMBER,
   p_default_last_updated_by    IN    NUMBER,
   p_default_last_update_login  IN    NUMBER,
   p_global_attribute1          IN    VARCHAR2,
   p_global_attribute2          IN    VARCHAR2,
   p_global_attribute3          IN    VARCHAR2,
   p_global_attribute4          IN    VARCHAR2,
   p_global_attribute5          IN    VARCHAR2,
   p_global_attribute6          IN    VARCHAR2,
   p_global_attribute7          IN    VARCHAR2,
   p_global_attribute8          IN    VARCHAR2,
   p_global_attribute9          IN    VARCHAR2,
   p_global_attribute10         IN    VARCHAR2,
   p_global_attribute11         IN    VARCHAR2,
   p_global_attribute12         IN    VARCHAR2,
   p_global_attribute13         IN    VARCHAR2,
   p_global_attribute14         IN    VARCHAR2,
   p_global_attribute15         IN    VARCHAR2,
   p_global_attribute16         IN    VARCHAR2,
   p_global_attribute17         IN    VARCHAR2,
   p_global_attribute18         IN    VARCHAR2,
   p_global_attribute19         IN    VARCHAR2,
   p_global_attribute20         IN    VARCHAR2,
   p_current_invoice_status     OUT NOCOPY   VARCHAR2,
   p_calling_sequence           IN    VARCHAR2
  );

PROCEDURE jl_ar_apxiisim_lines_folder
  (p_parent_id                  IN    NUMBER,
   p_default_last_updated_by    IN    NUMBER,
   p_default_last_update_login  IN    NUMBER,
   p_global_attribute1          IN    VARCHAR2,
   p_global_attribute2          IN    VARCHAR2,
   p_global_attribute3          IN    VARCHAR2,
   p_global_attribute4          IN    VARCHAR2,
   p_global_attribute5          IN    VARCHAR2,
   p_global_attribute6          IN    VARCHAR2,
   p_global_attribute7          IN    VARCHAR2,
   p_global_attribute8          IN    VARCHAR2,
   p_global_attribute9          IN    VARCHAR2,
   p_global_attribute10         IN    VARCHAR2,
   p_global_attribute11         IN    VARCHAR2,
   p_global_attribute12         IN    VARCHAR2,
   p_global_attribute13         IN    VARCHAR2,
   p_global_attribute14         IN    VARCHAR2,
   p_global_attribute15         IN    VARCHAR2,
   p_global_attribute16         IN    VARCHAR2,
   p_global_attribute17         IN    VARCHAR2,
   p_global_attribute18         IN    VARCHAR2,
   p_global_attribute19         IN    VARCHAR2,
   p_global_attribute20         IN    VARCHAR2,
   p_current_invoice_status     OUT NOCOPY   VARCHAR2,
   p_calling_sequence           IN    VARCHAR2
  );

-- Bug 3233307
PROCEDURE jl_co_apxiisim_invoices_folder
  (p_parent_id                  IN    NUMBER,
   p_default_last_updated_by    IN    NUMBER,
   p_default_last_update_login  IN    NUMBER,
   p_global_attribute1          IN    VARCHAR2,
   p_global_attribute2          IN    VARCHAR2,
   p_global_attribute3          IN    VARCHAR2,
   p_global_attribute4          IN    VARCHAR2,
   p_global_attribute5          IN    VARCHAR2,
   p_global_attribute6          IN    VARCHAR2,
   p_global_attribute7          IN    VARCHAR2,
   p_global_attribute8          IN    VARCHAR2,
   p_global_attribute9          IN    VARCHAR2,
   p_global_attribute10         IN    VARCHAR2,
   p_global_attribute11         IN    VARCHAR2,
   p_global_attribute12         IN    VARCHAR2,
   p_global_attribute13         IN    VARCHAR2,
   p_global_attribute14         IN    VARCHAR2,
   p_global_attribute15         IN    VARCHAR2,
   p_global_attribute16         IN    VARCHAR2,
   p_global_attribute17         IN    VARCHAR2,
   p_global_attribute18         IN    VARCHAR2,
   p_global_attribute19         IN    VARCHAR2,
   p_global_attribute20         IN    VARCHAR2,
   p_current_invoice_status     OUT NOCOPY   VARCHAR2,
   p_calling_sequence           IN    VARCHAR2
  );


PROCEDURE jl_co_apxiisim_lines_folder
  (p_parent_id                  IN    NUMBER,
   p_default_last_updated_by    IN    NUMBER,
   p_default_last_update_login  IN    NUMBER,
   p_global_attribute1          IN    VARCHAR2,
   p_global_attribute2          IN    VARCHAR2,
   p_global_attribute3          IN    VARCHAR2,
   p_global_attribute4          IN    VARCHAR2,
   p_global_attribute5          IN    VARCHAR2,
   p_global_attribute6          IN    VARCHAR2,
   p_global_attribute7          IN    VARCHAR2,
   p_global_attribute8          IN    VARCHAR2,
   p_global_attribute9          IN    VARCHAR2,
   p_global_attribute10         IN    VARCHAR2,
   p_global_attribute11         IN    VARCHAR2,
   p_global_attribute12         IN    VARCHAR2,
   p_global_attribute13         IN    VARCHAR2,
   p_global_attribute14         IN    VARCHAR2,
   p_global_attribute15         IN    VARCHAR2,
   p_global_attribute16         IN    VARCHAR2,
   p_global_attribute17         IN    VARCHAR2,
   p_global_attribute18         IN    VARCHAR2,
   p_global_attribute19         IN    VARCHAR2,
   p_global_attribute20         IN    VARCHAR2,
   p_current_invoice_status     OUT NOCOPY   VARCHAR2,
   p_calling_sequence           IN    VARCHAR2
  );


/*PROCEDURE ar_business_rules
     (p_calling_program_name            IN    VARCHAR2,
      p_sob_id                          IN    NUMBER,
      p_row_id                          IN    VARCHAR2,
      p_customer_name                   IN    VARCHAR2,
      p_customer_number                 IN    NUMBER,
      p_jgzz_fiscal_code                IN    VARCHAR2,
      p_generate_customer_number        IN    VARCHAR2,
      p_orig_system_customer_ref        IN    VARCHAR2,
      p_insert_update_flag              IN    VARCHAR2,
      p_request_id                      IN    NUMBER,
      p_global_attribute_category       IN    VARCHAR2,
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
      p_current_record_status           OUT NOCOPY   VARCHAR2);
*/
Procedure ar_business_rules
(   p_int_table_name                    IN VARCHAR2,
    p_glob_attr_set1	     	        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2		        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3		        IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg		        IN jg_globe_flex_val_shared.GenRec,
    p_current_record_status	        OUT NOCOPY   VARCHAR2);

PROCEDURE jl_cl_arxcudci_customers(
    p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_record_status                   OUT NOCOPY   VARCHAR2);

PROCEDURE jl_co_arxcudci_customers(
    p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_record_status                   OUT NOCOPY   VARCHAR2);

PROCEDURE jl_ar_arxcudci_customers(
    p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_record_status                   OUT NOCOPY   VARCHAR2);

PROCEDURE jl_zz_taxid_customers(
                p_country_code                  IN VARCHAR2,
                p_calling_program_name          IN VARCHAR2,
                p_row_id                        IN VARCHAR2,
                p_customer_name                 IN VARCHAR2,
                p_customer_number               IN VARCHAR2,
                p_jgzz_fiscal_code              IN VARCHAR2,
                p_generate_customer_number      IN VARCHAR2,
                p_orig_system_customer_ref      IN VARCHAR2,
                p_insert_update_flag            IN VARCHAR2,
                p_request_id                    IN NUMBER,
                p_global_attribute_category     IN VARCHAR2,
                p_global_attribute9             IN VARCHAR2,
                p_global_attribute10            IN VARCHAR2,
                p_global_attribute12            IN VARCHAR2,
                p_taxid_mesg_code              OUT NOCOPY VARCHAR2,
                p_taxid_record_status          OUT NOCOPY VARCHAR2);

PROCEDURE jl_br_apxiisim_invoices_folder
  (p_parent_id                  IN    NUMBER,
   p_default_last_updated_by    IN    NUMBER,
   p_default_last_update_login  IN    NUMBER,
   p_global_attribute1          IN    VARCHAR2,
   p_global_attribute2          IN    VARCHAR2,
   p_global_attribute3          IN    VARCHAR2,
   p_global_attribute4          IN    VARCHAR2,
   p_global_attribute5          IN    VARCHAR2,
   p_global_attribute6          IN    VARCHAR2,
   p_global_attribute7          IN    VARCHAR2,
   p_global_attribute8          IN    VARCHAR2,
   p_global_attribute9          IN    VARCHAR2,
   p_global_attribute10         IN    VARCHAR2,
   p_global_attribute11         IN    VARCHAR2,
   p_global_attribute12         IN    VARCHAR2,
   p_global_attribute13         IN    VARCHAR2,
   p_global_attribute14         IN    VARCHAR2,
   p_global_attribute15         IN    VARCHAR2,
   p_global_attribute16         IN    VARCHAR2,
   p_global_attribute17         IN    VARCHAR2,
   p_global_attribute18         IN    VARCHAR2,
   p_global_attribute19         IN    VARCHAR2,
   p_global_attribute20         IN    VARCHAR2,
   p_current_invoice_status     OUT NOCOPY   VARCHAR2,
   p_calling_sequence           IN    VARCHAR2
  );

PROCEDURE jl_br_apxiisim_lines_folder
  (p_parent_id                  IN    NUMBER,
   p_line_type_lookup_code      IN    VARCHAR2,
   p_default_last_updated_by    IN    NUMBER,
   p_default_last_update_login  IN    NUMBER,
   p_global_attribute1          IN    VARCHAR2,
   p_global_attribute2          IN    VARCHAR2,
   p_global_attribute3          IN    VARCHAR2,
   p_global_attribute4          IN    VARCHAR2,
   p_global_attribute5          IN    VARCHAR2,
   p_global_attribute6          IN    VARCHAR2,
   p_global_attribute7          IN    VARCHAR2,
   p_global_attribute8          IN    VARCHAR2,
   p_global_attribute9          IN    VARCHAR2,
   p_global_attribute10         IN    VARCHAR2,
   p_global_attribute11         IN    VARCHAR2,
   p_global_attribute12         IN    VARCHAR2,
   p_global_attribute13         IN    VARCHAR2,
   p_global_attribute14         IN    VARCHAR2,
   p_global_attribute15         IN    VARCHAR2,
   p_global_attribute16         IN    VARCHAR2,
   p_global_attribute17         IN    VARCHAR2,
   p_global_attribute18         IN    VARCHAR2,
   p_global_attribute19         IN    VARCHAR2,
   p_global_attribute20         IN    VARCHAR2,
   p_current_invoice_status     OUT NOCOPY   VARCHAR2,
   p_calling_sequence           IN    VARCHAR2
  );

PROCEDURE jl_br_apxiisim_val_cfo_code
  (p_parent_id                  IN    NUMBER,
   p_line_type_lookup_code      IN    VARCHAR2,
   p_default_last_updated_by    IN    NUMBER,
   p_default_last_update_login  IN    NUMBER,
   p_current_invoice_status     OUT NOCOPY   VARCHAR2,
   p_calling_sequence           IN    VARCHAR2
   );

Procedure jl_br_arxcudci_additional
(   p_glob_attr_set1		      IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2		      IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3		      IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg		      IN jg_globe_flex_val_shared.GenRec,
    p_record_status		      OUT NOCOPY   VARCHAR2);

PROCEDURE jl_br_customer_profiles
(   p_glob_attr_set1		      IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2		      IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3		      IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg		      IN jg_globe_flex_val_shared.GenRec,
    p_record_status		      OUT NOCOPY VARCHAR2);

procedure jl_zz_ar_tx_arxcudci_address
(   p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_record_status                   OUT NOCOPY   VARCHAR2);

procedure jl_zz_arxcudci_cust_txid
(   p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_record_status                   OUT NOCOPY   VARCHAR2);

PROCEDURE jl_cl_apxiisim_invoices_folder
  (p_parent_id                  IN    NUMBER,
   p_default_last_updated_by    IN    NUMBER,
   p_default_last_update_login  IN    NUMBER,
   p_global_attribute1          IN    VARCHAR2,
   p_global_attribute2          IN    VARCHAR2,
   p_global_attribute3          IN    VARCHAR2,
   p_global_attribute4          IN    VARCHAR2,
   p_global_attribute5          IN    VARCHAR2,
   p_global_attribute6          IN    VARCHAR2,
   p_global_attribute7          IN    VARCHAR2,
   p_global_attribute8          IN    VARCHAR2,
   p_global_attribute9          IN    VARCHAR2,
   p_global_attribute10         IN    VARCHAR2,
   p_global_attribute11         IN    VARCHAR2,
   p_global_attribute12         IN    VARCHAR2,
   p_global_attribute13         IN    VARCHAR2,
   p_global_attribute14         IN    VARCHAR2,
   p_global_attribute15         IN    VARCHAR2,
   p_global_attribute16         IN    VARCHAR2,
   p_global_attribute17         IN    VARCHAR2,
   p_global_attribute18         IN    VARCHAR2,
   p_global_attribute19         IN    VARCHAR2,
   p_global_attribute20         IN    VARCHAR2,
   p_current_invoice_status     OUT NOCOPY   VARCHAR2,
   p_calling_sequence           IN    VARCHAR2
  );


END JL_INTERFACE_VAL;

 

/
