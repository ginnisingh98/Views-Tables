--------------------------------------------------------
--  DDL for Package CN_GLOBAL_VAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GLOBAL_VAR" AUTHID CURRENT_USER AS
-- $Header: cnsygin1s.pls 120.1 2005/07/06 18:47:42 appldev ship $
--
-- Package Name
--   cn
-- Purpose
--   This package is used to initialize global variables for the 'current'
--   commissions instance
--
-- History
--   16-JUN-94 P Cook		Created
--   08-MAY-95 P Cook		Added srp_batch_size
--   19-SEP-95 P Cook		Added currency code
--   05-MAR-02 S Venkat         Replace global variable g_srp_batch_size with function g_srp_batch_size
--   30-May-02 S Venkat	        Bring g_salesrep_batch_size/package name change(cn_global_var) in sync

-- Define global variables
  g_curr_period_name         		VARCHAR2(30)	;
  g_repository_id 	     		NUMBER		;
  g_rev_class_hierarchy_id   		NUMBER		;
  g_srp_rollup_hierarchy_id  		NUMBER		;
  g_curr_period_id	     		NUMBER		;
  g_curr_period_start_date   		DATE		;
  g_curr_period_end_date     		DATE		;
  g_system_batch_size	     		NUMBER		;
  g_transfer_batch_size	     		NUMBER		;
  g_srp_rollup_flag	     		VARCHAR2(1)	;
  g_curr_prd_rev_class_hier_id		NUMBER		;
  g_curr_prd_srp_rollup_hier_id		NUMBER		;
--  g_srp_batch_size			        NUMBER		;
  g_cls_package_size			    NUMBER		;
--  g_salesrep_batch_size                 NUMBER          ;
  g_system_start_period_id	  	NUMBER		;
  g_system_start_date	  		DATE		;
  g_set_of_books_id			NUMBER		;
  gl_currency_code			VARCHAR2(15)	;
  g_precision           NUMBER;
  g_ext_precision       NUMBER;
  g_min_acct_unit       NUMBER;

  --
  -- Global record type
  --
TYPE attribute_rec_type IS RECORD
  (attribute_category   VARCHAR2(30)          := NULL,
   attribute1           VARCHAR2(150)         := NULL,
   attribute2           VARCHAR2(150)         := NULL,
   attribute3           VARCHAR2(150)         := NULL,
   attribute4           VARCHAR2(150)         := NULL,
   attribute5           VARCHAR2(150)         := NULL,
   attribute6           VARCHAR2(150)         := NULL,
   attribute7           VARCHAR2(150)         := NULL,
   attribute8           VARCHAR2(150)         := NULL,
   attribute9           VARCHAR2(150)         := NULL,
   attribute10          VARCHAR2(150)         := NULL,
   attribute11          VARCHAR2(150)         := NULL,
   attribute12          VARCHAR2(150)         := NULL,
   attribute13          VARCHAR2(150)         := NULL,
   attribute14          VARCHAR2(150)         := NULL,
   attribute15          VARCHAR2(150)         := NULL
   );

G_MISS_ATTRIBUTE_REC attribute_rec_type;

  --
  -- Procedure Name
  --   instance_info
  -- Purpose
  --   Retrieve global variables and pass them thru parameters
  --   Used when accessing globals from sqlforms.
  --
  -- Notes
  --
  -- History
  --   16-JUN-94		P Cook		Created
  --
/*
 PROCEDURE instance_info(x_repository_id	         OUT NOCOPY NUMBER	,
			 x_rev_class_hierarchy_id        OUT NOCOPY NUMBER	,
			 x_srp_rollup_hierarchy_id       OUT NOCOPY NUMBER	,
			 x_curr_period_id	         OUT NOCOPY NUMBER	,
			 x_curr_period_name           IN OUT NOCOPY VARCHAR2	,
			 x_curr_period_start_date        OUT NOCOPY DATE	,
			 x_curr_period_end_date          OUT NOCOPY DATE	,
			 x_system_batch_size	         OUT NOCOPY NUMBER	,
			 x_transfer_batch_size	         OUT NOCOPY NUMBER	,
			 x_srp_rollup_flag	      IN OUT NOCOPY VARCHAR2	,
			 x_curr_prd_rev_class_hier_id    OUT NOCOPY NUMBER	,
   			 x_curr_prd_srp_rollup_hier_id   OUT NOCOPY NUMBER	,
			 x_srp_batch_size		 OUT NOCOPY NUMBER	,
			 x_cls_package_size		 OUT NOCOPY NUMBER	,
			 x_system_start_period_id	 OUT NOCOPY NUMBER	,
			 x_system_start_date		 OUT NOCOPY DATE	,
			 x_currency_code		 OUT NOCOPY VARCHAR2	);

*/

 FUNCTION get_currency_code(p_org_id IN NUMBER) RETURN VARCHAR2;

 --new method included by Sundar Venkat on 05 March 2002
 --this function replaces the existing global variable g_srp_batch_size
 --this is used in posting_details
 FUNCTION get_srp_batch_size(p_org_id IN NUMBER) RETURN NUMBER;
 FUNCTION get_salesrep_batch_size(p_org_id IN NUMBER) RETURN NUMBER;

 PROCEDURE initialize_instance_info(p_org_id IN NUMBER);


END cn_global_var;

 

/
