--------------------------------------------------------
--  DDL for Package FEM_INTG_NEW_DIM_MEMBER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_INTG_NEW_DIM_MEMBER_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_intg_dimmemb.pls 120.5 2008/02/23 00:34:08 rguerrer noship $ */

  pv_local_member_col                  VARCHAR2(30);

  PROCEDURE Populate_Dimension_Attribute(
    p_summary_flag IN VARCHAR,
    x_completion_code OUT NOCOPY NUMBER,
    x_row_count_tot OUT NOCOPY NUMBER
  );

  -- commented for bug fix 5377544
  -- Restored for bug fix 5560443
  PROCEDURE Detail_Single_Value(
    x_completion_code OUT NOCOPY NUMBER,
    x_row_count_tot   OUT NOCOPY NUMBER
  );


  PROCEDURE Detail_Single_Segment(
    x_completion_code OUT NOCOPY NUMBER,
    x_row_count_tot   OUT NOCOPY NUMBER
  );

  PROCEDURE Detail_Multi_Segment(
    x_completion_code OUT NOCOPY NUMBER,
    x_row_count_tot   OUT NOCOPY NUMBER,
    p_calling_module IN varchar default null
  );

  PROCEDURE Create_Parent_Members(
    x_completion_code OUT NOCOPY NUMBER
  );

  -- Added for bug fix 5377544
  PROCEDURE fem_intg_dim_rule_worker( X_errbuf                    OUT NOCOPY VARCHAR2,
                                      X_retcode                   OUT NOCOPY VARCHAR2,
                                      p_batch_size                IN NUMBER,
                                      p_Worker_Id                 IN NUMBER,
                                      p_Num_Workers               IN NUMBER,
                                      p_coa_id                    IN VARCHAR2,
                                      p_gvsc_id                   IN VARCHAR2,
                                      p_max_ccid_processed        IN VARCHAR2,
                                      p_max_ccid_to_be_mapped     IN VARCHAR2
                                     );

  TYPE ccid_list_type IS TABLE OF NUMBER;

END fem_intg_new_dim_member_pkg;

/
