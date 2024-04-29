--------------------------------------------------------
--  DDL for Package JAI_CMN_MTAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_MTAX_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_mtax.pls 120.4 2007/06/19 10:31:32 sacsethi ship $ */

  gn_commit_interval CONSTANT NUMBER DEFAULT 50 ; --Added global variable gn_commit_interval in package spec. by rpokkula for File.Sql.35

  /*START, Added the following procedures by Bgowrava for the forward porting Bug#5724855 */

     procedure route_request
	    (
	         p_err_buf                 OUT NOCOPY VARCHAR2
	        ,p_ret_code                OUT NOCOPY VARCHAR2
	        ,p_org_id                  IN NUMBER             --1
	        ,p_document_type           IN VARCHAR2  default null      --2
	        ,p_from_date               IN varchar2      default null      --3
	        ,p_to_date                 IN varchar2      default null        --4
	        ,p_supplier_id             IN NUMBER    default null      --5
	        ,p_supplier_site_id        IN NUMBER    default null   --6
	        ,p_customer_id             IN NUMBER    default null      --7
	        ,p_customer_site_id        IN NUMBER    default null   --8
	        ,p_old_tax_category        IN NUMBER       --9
	        ,p_new_tax_category        IN NUMBER       --10
	        ,p_document_no             IN VARCHAR2  default null        --11
	        ,p_release_no              IN NUMBER    default null       --12
	        ,p_document_line_no        IN NUMBER    default null   --13
	        ,p_shipment_no             IN NUMBER    default null      --14
	        ,p_override_manual_taxes   IN CHAR      default 'N'--15
	        ,p_commit_interval         IN NUMBER    default 50   --16
	        ,p_process_partial         IN CHAR      default 'N'    --17
	        ,p_debug                   IN CHAR      default 'N'        --18
	        ,p_trace                   IN CHAR      default 'N'         --19
	        ,p_dbms_output             IN CHAR      default 'N' -- this can be used when developer tests this from backened to get dbms output at important points
	        ,p_called_from             IN VARCHAR2  default null
	        ,p_source_id               IN NUMBER    default null -- this can be used to pass identifier based on which routing can be done
	    );

	    procedure process_tax_cat_update
	    (
	         p_err_buf                 OUT NOCOPY VARCHAR2
	        ,p_ret_code                OUT NOCOPY VARCHAR2
	        ,p_org_id                  IN NUMBER             --1
	        ,p_document_type           IN VARCHAR2  default null      --2
	        ,p_from_date               IN DATE            --3
	        ,p_to_date                 IN DATE              --4
	        ,p_supplier_id             IN NUMBER          --5
	        ,p_supplier_site_id        IN NUMBER       --6
	        ,p_customer_id             IN NUMBER          --7
	        ,p_customer_site_id        IN NUMBER       --8
	        ,p_old_tax_category        IN NUMBER       --9
	        ,p_new_tax_category        IN NUMBER       --10
	        ,p_document_no             IN VARCHAR2          --11
	        ,p_release_no              IN NUMBER           --12
	        ,p_document_line_no        IN NUMBER       --13
	        ,p_shipment_no             IN NUMBER          --14
	        ,p_override_manual_taxes   IN CHAR DEFAULT 'N'--15
	        ,p_commit_interval         IN NUMBER DEFAULT 50   --16
	        ,p_process_partial         IN CHAR DEFAULT 'N'    --17
	        ,p_debug                   IN CHAR DEFAULT 'N'        --18
	        ,p_trace                   IN CHAR DEFAULT 'N'         --19
	        ,p_dbms_output             IN CHAR DEFAULT 'N'
	        ,p_tax_cat_update_id       IN jai_cmn_taxctg_updates.tax_category_update_id%type
	    );


  /*END, by Bgowrava for the forward porting Bug#5724855*/



  PROCEDURE do_tax_redefaultation
  (
    p_err_buf OUT NOCOPY VARCHAR2,
    p_ret_code  OUT NOCOPY VARCHAR2,
    p_org_id IN NUMBER,             --1
    p_document_type IN VARCHAR2,        --2
    pv_from_date IN VARCHAR2,            --3 rpokkula for bug# 4336482 changed from DATE to VARCHAR2
    pv_to_date IN VARCHAR2,              --4 rpokkula for bug# 4336482 changed from DATE to VARCHAR2
    p_supplier_id IN NUMBER,          --5
    p_supplier_site_id IN NUMBER,       --6
    p_customer_id IN NUMBER,          --7
    p_customer_site_id IN NUMBER,       --8
    p_old_tax_category IN NUMBER,       --9
    p_new_tax_category IN NUMBER,       --10
    p_document_no IN VARCHAR2,          --11
    p_release_no IN NUMBER,           --12
    p_document_line_no IN NUMBER,       --13
    p_shipment_no IN NUMBER,          --14
    pv_override_manual_taxes IN VARCHAR2,       -- DEFAULT 'N',--15      -- Use jai_constants.no in the call of this procedure. rpokkula for for File.Sql.35
    pn_commit_interval IN NUMBER,           -- DEFAULT 50,   --16    -- Added global variable gn_commit_interval in package spec. by rpokkula for File.Sql.35
    pv_process_partial IN VARCHAR2,             -- DEFAULT 'N',    --17  -- Use jai_constants.no in the call of this procedure. rpokkula for for File.Sql.35
    pv_debug IN VARCHAR2,                       -- DEFAULT 'N',    --18  -- Use jai_constants.no in the call of this procedure. rpokkula for for File.Sql.35
    pv_trace IN VARCHAR2                       -- DEFAULT 'N'     --19  -- Use jai_constants.no in the call of this procedure. rpokkula for for File.Sql.35
  );

   PROCEDURE del_taxes_after_validate
  (
    p_document_type IN VARCHAR2,	-- eg. PO, SO, REQUISITION
    p_line_focus_id IN NUMBER,		-- IF 'PO' this should contain JAI_PO_LINE_LOCATIONS.line_focus_id and
    p_line_location_id IN NUMBER,
    p_line_id IN NUMBER,			-- if 'SO' then this should contain JAI_OM_OE_SO_LINES.line_id
    p_success OUT NOCOPY NUMBER,
    p_message OUT NOCOPY VARCHAR2
  );

END jai_cmn_mtax_pkg;

/
