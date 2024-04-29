--------------------------------------------------------
--  DDL for Package CN_CALC_SUB_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_SUB_BATCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: cnsbbats.pls 120.1 2005/06/10 14:04:06 appldev  $ */

TYPE calc_sub_batch_rec_type IS RECORD
  (  calc_sub_batch_id   cn_calc_submission_batches.calc_sub_batch_id%TYPE,
     name                cn_calc_submission_batches.name%TYPE,
     intelligent_flag    cn_calc_submission_batches.intelligent_flag%TYPE,
     hierarchy_flag      cn_calc_submission_batches.hierarchy_flag%TYPE,
     salesrep_option     cn_calc_submission_batches.salesrep_option%TYPE,
     -- concurrent_flag     cn_calc_submission_batches.concurrent_flag%TYPE,
     logical_batch_id    cn_calc_submission_batches.logical_batch_id%TYPE,
     start_date          cn_calc_submission_batches.start_date%TYPE,
     end_date            cn_calc_submission_batches.end_date%TYPE,
     calc_type           cn_calc_submission_batches.calc_type%TYPE,
     -- ledger_je_batch_id  cn_calc_submission_batches.ledger_je_batch_id%TYPE,
     interval_type_id    cn_calc_submission_batches.interval_type_id%TYPE       );


--
--
--
-- This Procedure is called to
-- 	1. Insert
-- 	2. Update
-- 	3. Delete
-- Records into Table cn_calc_submission_batches
--
--
--
Procedure Begin_Record ( P_OPERATION              VARCHAR2,
			 p_calc_sub_batch_id      NUMBER := NULL,
			 p_name                   VARCHAR2 := NULL,
			 p_start_date             DATE := NULL,
			 p_end_date               DATE := NULL,
			 p_intelligent_flag       VARCHAR2 := NULL,
			 p_hierarchy_flag         VARCHAR2 := NULL,
			 p_salesrep_option        VARCHAR2 := NULL,
			 p_concurrent_flag        VARCHAR2 := NULL,
			 p_status                 VARCHAR2 := NULL,
			 p_logical_batch_id       NUMBER := NULL,
			 p_calc_type              VARCHAR2 := NULL,
			 p_interval_type_id       NUMBER := NULL,
             p_org_id                 NUMBER,
			 p_log_name               VARCHAR2 := NULL,
                         P_ATTRIBUTE_CATEGORY     VARCHAR2 := NULL,
                         P_ATTRIBUTE1             VARCHAR2 := NULL,
                         P_ATTRIBUTE2             VARCHAR2 := NULL,
                         P_ATTRIBUTE3             VARCHAR2 := NULL,
                         P_ATTRIBUTE4             VARCHAR2 := NULL,
                         P_ATTRIBUTE5             VARCHAR2 := NULL,
                         P_ATTRIBUTE6             VARCHAR2 := NULL,
			 P_ATTRIBUTE7             VARCHAR2 := NULL,
                         P_ATTRIBUTE8             VARCHAR2 := NULL,
                         P_ATTRIBUTE9             VARCHAR2 := NULL,
                         P_ATTRIBUTE10            VARCHAR2 := NULL,
                         P_ATTRIBUTE11            VARCHAR2 := NULL,
                         P_ATTRIBUTE12            VARCHAR2 := NULL,
                         P_ATTRIBUTE13            VARCHAR2 := NULL,
                         P_ATTRIBUTE14            VARCHAR2 := NULL,
                         P_ATTRIBUTE15            VARCHAR2 := NULL,
                         P_CREATED_BY             NUMBER   := NULL,
                         P_CREATION_DATE          DATE     := NULL,
                         P_LAST_UPDATE_LOGIN      NUMBER   := NULL,
                         P_LAST_UPDATE_DATE       DATE     := NULL,
                         P_LAST_UPDATED_BY        NUMBER   := NULL
  );

  --+
  -- Procedure Name
  --   get_calc_sub_batch
  -- Scope
  --    public
  -- Purpose
  --   get the calc_submission for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
PROCEDURE get_calc_sub_batch ( p_physical_batch_id  NUMBER,
			       x_calc_sub_batch_rec OUT NOCOPY calc_sub_batch_rec_type );

  --+
  -- Procedure Name
  --   get_intel_calc_flag
  -- Scope
  --    public
  -- Purpose
  --   get the intelligent_flag for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  FUNCTION  get_intel_calc_flag (p_calc_batch_id NUMBER) RETURN VARCHAR2;


  --+
  -- Procedure Name
  --   get_forecast_flag
  -- Scope
  --   public
  -- Purpose
  --   get the intelligent_flag for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  FUNCTION  get_forecast_flag (p_calc_batch_id NUMBER) RETURN VARCHAR2 ;

  --+
  -- Procedure Name
  --   get_calc_type
  -- Scope
  --   public
  -- Purpose
  --   get the calculation type for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+

  FUNCTION  get_calc_type (p_calc_batch_id NUMBER) RETURN VARCHAR2  ;

  --+
  -- Procedure Name
  --   get_concurrent_flag
  -- Scope
  --   public
  -- Purpose
  --   get the concurrent flag for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  FUNCTION  get_concurrent_flag (p_calc_sub_batch_id NUMBER) RETURN VARCHAR2 ;

  --+
  -- Procedure Name
  --   get_salesrep_option
  -- Scope
  --   public
  -- Purpose
  --   get the calculation type for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+

  FUNCTION  get_salesrep_option (p_calc_batch_id NUMBER) RETURN VARCHAR2 ;

  --+
  -- Procedure Name
  --  get_calc_sub_batch_id
  -- Scope
  --   public
  -- Purpose
  --   get new calc_sub_batch_id
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  FUNCTION get_calc_sub_batch_id  RETURN NUMBER;

  --+
  -- Procedure Name
  --  delete_calc_sub_batch
  -- Scope
  --   public
  -- Purpose
  --   delete a calc submission batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  PROCEDURE delete_calc_sub_batch (p_calc_sub_batch_id NUMBER);

  --+
  -- Procedure Name
  --  update_calc_sub_batch
  -- Scope
  --   public
  -- Purpose
  --   update status of a calc submission batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  PROCEDURE update_calc_sub_batch (p_logical_batch_id NUMBER,
				   p_status	     VARCHAR2);

END cn_calc_sub_batches_pkg;
 

/
