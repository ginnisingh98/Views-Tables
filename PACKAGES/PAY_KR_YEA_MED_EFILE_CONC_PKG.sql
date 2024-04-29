--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_MED_EFILE_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_MED_EFILE_CONC_PKG" AUTHID CURRENT_USER as
/*$Header: pykrymcon.pkh 120.1 2006/10/20 08:44:34 vaisriva noship $ */
--
/*************************************************************************
 * Procedure to submit e-file request indirectly
 *************************************************************************/

   procedure submit_efile
                (errbuf                   out nocopy  varchar2,
		 retcode                  out nocopy  varchar2,
		 p_business_place	  in varchar2,
		 p_REPORT_FOR		  in varchar2,		--5069923
		 p_magnetic_file_name	  in varchar2,
	         p_report_file_name	  in varchar2,
		 p_effective_date	  in varchar2,
		 p_PAYROLL_ACTION	  in varchar2,
		 p_ASSIGNMENT_SET	  in varchar2,
		 p_REPORT_TYPE	          in varchar2,
		 p_reported_date          in varchar2,
		 p_TARGET_YEAR	          in varchar2,
		 p_CHARACTERSET	          in varchar2,
		 p_HOME_TAX_ID            in varchar2,
		 p_ORG_STRUC_VERSION_ID   in varchar2		--5069923
		);

   procedure get_bg_id
              ( p_business_place in  varchar2,
                l_bg_id out nocopy number);

   function validate_det_medical_rec
              ( p_assignment_id           in number,
                p_yea_date                in date
               )
              return varchar2;

   function get_medical_reg_no
              ( p_assignment_id           in number,
                p_yea_date                in date ,
                p_medical_reg_no          in varchar2
               )
              return varchar2;

   function get_resident_reg_no
              ( p_assignment_id           in number,
                p_yea_date                in date ,
                p_resident_reg_no         in varchar2
               )
              return varchar2;
   --
end pay_kr_yea_med_efile_conc_pkg;

/
