--------------------------------------------------------
--  DDL for Package JG_GLOBE_FLEX_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_GLOBE_FLEX_VAL" AUTHID CURRENT_USER AS
/* $Header: jggdfvs.pls 120.6.12010000.2 2009/09/07 16:04:41 mbarrett ship $ */
--
-- Commented the following record definition as this has been moved
-- to jggdfvss.pls which is the shared procedure, to avoid cyclic references.
-- Needs to be deleted.
-- Record type is introduced to handle global_attributes
--
/*
TYPE GdfRec IS RECORD
     (global_attribute_category   VARCHAR2(30)    DEFAULT NULL,
      global_attribute1           VARCHAR2(150)   DEFAULT NULL,
      global_attribute2           VARCHAR2(150)   DEFAULT NULL,
      global_attribute3           VARCHAR2(150)   DEFAULT NULL,
      global_attribute4           VARCHAR2(150)   DEFAULT NULL,
      global_attribute5           VARCHAR2(150)   DEFAULT NULL,
      global_attribute6           VARCHAR2(150)   DEFAULT NULL,
      global_attribute7           VARCHAR2(150)   DEFAULT NULL,
      global_attribute8           VARCHAR2(150)   DEFAULT NULL,
      global_attribute9           VARCHAR2(150)   DEFAULT NULL,
      global_attribute10          VARCHAR2(150)   DEFAULT NULL,
      global_attribute11          VARCHAR2(150)   DEFAULT NULL,
      global_attribute12          VARCHAR2(150)   DEFAULT NULL,
      global_attribute13          VARCHAR2(150)   DEFAULT NULL,
      global_attribute14          VARCHAR2(150)   DEFAULT NULL,
      global_attribute15          VARCHAR2(150)   DEFAULT NULL,
      global_attribute16          VARCHAR2(150)   DEFAULT NULL,
      global_attribute17          VARCHAR2(150)   DEFAULT NULL,
      global_attribute18          VARCHAR2(150)   DEFAULT NULL,
      global_attribute19          VARCHAR2(150)   DEFAULT NULL,
      global_attribute20          VARCHAR2(150)   DEFAULT NULL
      );

TYPE GenRec IS RECORD
     (core_prod_arg1              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg2              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg3              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg4              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg5              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg6              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg7              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg8              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg9              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg10             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg11             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg12             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg13             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg14             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg15             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg16             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg17             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg18             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg19             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg20             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg21             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg22             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg23             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg24             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg25             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg26             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg27             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg28             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg29             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg30             VARCHAR2(150)   DEFAULT NULL
     );
*/

FUNCTION reassign_context_code
     (p_global_context_code        IN OUT NOCOPY     VARCHAR2) RETURN BOOLEAN;

PROCEDURE check_attr_value
     (p_calling_program_name       IN     VARCHAR2,
      p_global_attribute_category  IN     VARCHAR2,
      p_global_attribute1          IN OUT NOCOPY    VARCHAR2,
      p_global_attribute2          IN OUT NOCOPY    VARCHAR2,
      p_global_attribute3          IN OUT NOCOPY    VARCHAR2,
      p_global_attribute4          IN OUT NOCOPY    VARCHAR2,
      p_global_attribute5          IN OUT NOCOPY    VARCHAR2,
      p_global_attribute6          IN OUT NOCOPY    VARCHAR2,
      p_global_attribute7          IN OUT NOCOPY    VARCHAR2,
      p_global_attribute8          IN OUT NOCOPY    VARCHAR2,
      p_global_attribute9          IN OUT NOCOPY    VARCHAR2,
      p_global_attribute10         IN OUT NOCOPY    VARCHAR2,
      p_global_attribute11         IN OUT NOCOPY    VARCHAR2,
      p_global_attribute12         IN OUT NOCOPY    VARCHAR2,
      p_global_attribute13         IN OUT NOCOPY    VARCHAR2,
      p_global_attribute14         IN OUT NOCOPY    VARCHAR2,
      p_global_attribute15         IN OUT NOCOPY    VARCHAR2,
      p_global_attribute16         IN OUT NOCOPY    VARCHAR2,
      p_global_attribute17         IN OUT NOCOPY    VARCHAR2,
      p_global_attribute18         IN OUT NOCOPY    VARCHAR2,
      p_global_attribute19         IN OUT NOCOPY    VARCHAR2,
      p_global_attribute20         IN OUT NOCOPY    VARCHAR2,
      p_core_prod_arg1             IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg2             IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg3             IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg4             IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg5             IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg6             IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg7             IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg8             IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg9             IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg10            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg11            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg12            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg13            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg14            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg15            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg16            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg17            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg18            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg19            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg20            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg21            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg22            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg23            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg24            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg25            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg26            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg27            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg28            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg29            IN     VARCHAR2 DEFAULT NULL,
      p_core_prod_arg30            IN     VARCHAR2 DEFAULT NULL,
      p_current_status	           OUT NOCOPY    VARCHAR2
      );

PROCEDURE check_attr_value_ap(
      p_calling_program_name  		IN    VARCHAR2,
      p_set_of_books_id     		IN    NUMBER,
      p_invoice_date                    IN    DATE,
      p_parent_table          		IN    VARCHAR2,
      p_parent_id          		IN    NUMBER,
      p_default_last_updated_by		IN    NUMBER,
      p_default_last_update_login	IN    NUMBER,
      p_inv_vendor_site_id		IN    NUMBER,
      p_inv_payment_currency_code	IN    VARCHAR2,
      p_line_type_lookup_code           IN    VARCHAR2,
      p_global_attribute_category       IN    VARCHAR2,
      p_global_attribute1   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute2   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute3   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute4   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute5   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute6   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute7   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute8   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute9   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute10  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute11  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute12  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute13  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute14  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute15  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute16  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute17  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute18  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute19  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute20  		IN OUT NOCOPY    VARCHAR2,
      p_current_invoice_status		OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2);

PROCEDURE check_ap_context_integrity
     (p_calling_program_name            IN    VARCHAR2,
      p_parent_table                    IN    VARCHAR2,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
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


PROCEDURE reject_value_found(
      p_parent_table                    IN    VARCHAR2,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
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

PROCEDURE reject_invalid_context_code(
      p_calling_program_name            IN    VARCHAR2,
      p_parent_table                    IN    VARCHAR2,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute_category       IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2);

PROCEDURE check_ap_business_rules(
      p_calling_program_name		IN    VARCHAR2,
      p_set_of_books_id                 IN    NUMBER,
      p_invoice_date                    IN    DATE,
      p_parent_table                    IN    VARCHAR2,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_inv_vendor_site_id              IN    NUMBER,
      p_inv_payment_currency_code       IN    VARCHAR2,
      p_line_type_lookup_code           IN    VARCHAR2,
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

--
-- Modified to implement new TCA model.
-- Added one more parameter p_int_table_name, which receives the following
-- values currently as valid : CUSTOMER or PROFILE.
--
PROCEDURE ar_cust_interface(p_request_id         IN   NUMBER,
                            p_org_id             IN   NUMBER,
                            p_sob_id             IN   NUMBER,
                            p_user_id            IN   NUMBER,
                            p_application_id     IN   NUMBER,
                            p_language           IN   NUMBER,
                            p_program_id         IN   NUMBER,
                            p_prog_appl_id       IN   NUMBER,
                            p_last_update_login  IN   NUMBER,
			    p_int_table_name	 IN   VARCHAR2);

--
-- Modified check_attr_value_ar to implement the new TCA model.
-- Modified parameter type to have record type variables.
--
PROCEDURE check_attr_value_ar
     (p_int_table_name           IN     VARCHAR2,
      p_glob_attr_set1           IN     jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_set2           IN     jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_set3           IN     jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_general        IN     jg_globe_flex_val_shared.GenRec,
      p_current_record_status    OUT NOCOPY    VARCHAR2
      );
--
-- End of modification
--

--
-- Modified check_ar_context_integrity parameters to implement TCA model.
--
  PROCEDURE check_ar_context_integrity(
         p_int_table_name           IN     VARCHAR2,
         p_glob_attr_set1           IN     jg_globe_flex_val_shared.GdfRec,
         p_glob_attr_set2           IN     jg_globe_flex_val_shared.GdfRec,
         p_glob_attr_set3           IN     jg_globe_flex_val_shared.GdfRec,
         p_glob_attr_general        IN     jg_globe_flex_val_shared.GenRec,
         p_current_record_status    OUT NOCOPY    VARCHAR2);

--
-- End of modification
--

--
-- Modified check_ar_business_rules  parameters to implement TCA model.
--

  PROCEDURE check_ar_business_rules(
      p_int_table_name            IN    VARCHAR2,
      p_glob_attr_set1            IN    jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_set2            IN    jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_set3            IN    jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_general         IN    jg_globe_flex_val_shared.GenRec,
      p_current_record_status     OUT NOCOPY   VARCHAR2,
      p_org_id                    IN  NUMBER); --2354736
--
-- End of modification
--

PROCEDURE insert_jg_zz_invoice_info
     (p_invoice_id                      IN     NUMBER,
      p_global_attribute_category       IN OUT NOCOPY VARCHAR2,
      p_global_attribute1               IN OUT NOCOPY VARCHAR2,
      p_global_attribute2               IN OUT NOCOPY VARCHAR2,
      p_global_attribute3               IN OUT NOCOPY VARCHAR2,
      p_global_attribute4               IN OUT NOCOPY VARCHAR2,
      p_global_attribute5               IN OUT NOCOPY VARCHAR2,
      p_global_attribute6               IN OUT NOCOPY VARCHAR2,
      p_global_attribute7               IN OUT NOCOPY VARCHAR2,
      p_global_attribute8               IN OUT NOCOPY VARCHAR2,
      p_global_attribute9               IN OUT NOCOPY VARCHAR2,
      p_global_attribute10              IN OUT NOCOPY VARCHAR2,
      p_global_attribute11              IN OUT NOCOPY VARCHAR2,
      p_global_attribute12              IN OUT NOCOPY VARCHAR2,
      p_global_attribute13              IN OUT NOCOPY VARCHAR2,
      p_global_attribute14              IN OUT NOCOPY VARCHAR2,
      p_global_attribute15              IN OUT NOCOPY VARCHAR2,
      p_global_attribute16              IN OUT NOCOPY VARCHAR2,
      p_global_attribute17              IN OUT NOCOPY VARCHAR2,
      p_global_attribute18              IN OUT NOCOPY VARCHAR2,
      p_global_attribute19              IN OUT NOCOPY VARCHAR2,
      p_global_attribute20              IN OUT NOCOPY VARCHAR2,
      p_last_updated_by                 IN     NUMBER,
      p_last_update_date                IN     DATE,
      p_last_update_login               IN     NUMBER,
      p_created_by                      IN     NUMBER,
      p_creation_date                   IN     DATE,
      p_calling_sequence                IN     VARCHAR2);

--
-- Added to implement the TCA model.
--
PROCEDURE insert_global_tables
     (p_table_name                      IN VARCHAR2,
      p_key_column1                     IN VARCHAR2,
      p_key_column2                     IN VARCHAR2,
      p_key_column3                     IN VARCHAR2,
      p_key_column4                     IN VARCHAR2,
      p_key_column5                     IN VARCHAR2,
      p_key_column6                     IN VARCHAR2);

-- Bug 8859419 Start

   Type G_GDF_CONTEXT_REC is RECORD (global_attribute_category ap_invoice_distributions_all.global_attribute_category%Type);
   TypE G_GDF_CONTEXT_TAB is TABLE of g_gdf_context_rec INDEX BY VARCHAR2(150);
   G_GDF_CONTEXT_T G_GDF_CONTEXT_TAB;

   Function Gdf_Context_Exists(p_gdf_context in varchar2) Return Boolean;

-- Bug 8859419 End

END jg_globe_flex_val;

/
