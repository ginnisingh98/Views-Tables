--------------------------------------------------------
--  DDL for Package PSB_EXCEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_EXCEL_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVXLES.pls 115.5 2002/11/18 16:31:11 mgoel ship $ */


/* ----------------------------------------------------------------------- */
  --    API name        : Move_To_Interface
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --    Parameters      :
  --    IN              : p_export_name               IN   VARCHAR2 Required
  --                      p_worksheet_id              IN   NUMBER   Required
  --                      p_stage_id                  IN   NUMBER   Optional
  --                      p_export_worksheet_type     IN   VARCHAR2 Optional
  --                               (B-Both (default), A-Account, P-Position)
  --    Version : Current version       1.0
  --              Initial version       1.0
  --              Created 10/16/1997 by L Sekar
  --
  --    Notes           : Moves data from  PSB to Interface

PROCEDURE Move_To_Interface
(
  p_api_version               IN   NUMBER   ,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY  VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY  NUMBER   ,
  p_msg_data                  OUT  NOCOPY  VARCHAR2 ,
  --
  p_export_name               IN   VARCHAR2,
  p_worksheet_id              IN   NUMBER,
  p_stage_id                  IN   NUMBER   := FND_API.G_MISS_NUM,
  p_export_worksheet_type     IN   VARCHAR2 := FND_API.G_MISS_CHAR
);

/* ----------------------------------------------------------------------- */
  --    API name        : Move_To_PSB
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --    Parameters      :
  --    IN              : p_export_id                 IN   NUMBER   Required
  --                      p_import_worksheet_type     IN   VARCHAR2 Optional
  --                              ( B-Both (default), A-Account, P-Position)
  --                      p_amt_tolerance_value_type  IN   VARCHAR2 Optional
  --                      p_amt_tolerance_value       IN   NUMBER   Optional
  --                      p_pct_tolerance_value_type  IN   VARCHAR2 Optional
  --                      p_pct_tolerance_value       IN   NUMBER   Optional
  --
  --    Version : Current version       1.0
  --              Initial version       1.0
  --              Created 10/16/1997 by L Sekar
  --
  --    Notes           : Moves data from Interface to PSB

PROCEDURE Move_To_PSB
(
  p_api_version               IN   NUMBER   ,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY  VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY  NUMBER   ,
  p_msg_data                  OUT  NOCOPY  VARCHAR2 ,
  --
  p_export_id                 IN   NUMBER,
  p_import_worksheet_type     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_amt_tolerance_value_type  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_amt_tolerance_value       IN   NUMBER   := FND_API.G_MISS_NUM,
  p_pct_tolerance_value_type  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_pct_tolerance_value       IN   NUMBER   := FND_API.G_MISS_NUM
  );

/* ----------------------------------------------------------------------- */


-- To store WS Columns
TYPE g_ws_col_rec_type IS RECORD
     ( budget_year_id  NUMBER,
       budget_year_name VARCHAR2(15),
       balance_type    VARCHAR2(1),
/* Bug No 2656353 Start */
--       display_balance_type VARCHAR2(10),
       display_balance_type VARCHAR2(15),
/* Bug No 2656353 End */
       year_category_type VARCHAR2(2)
     );

TYPE g_ws_col_tbl_type IS TABLE OF g_ws_col_rec_type
      INDEX BY BINARY_INTEGER;
g_ws_cols  g_ws_col_tbl_type;

-- To store Position WS Columns
TYPE g_pos_ws_col_rec_type IS RECORD
     ( column_type     VARCHAR2(1),
       budget_year_id  NUMBER,
       budget_year_name VARCHAR2(15),
       budget_period_id  NUMBER,
       budget_period_name VARCHAR2(15),
       balance_type    VARCHAR2(1),
/* Bug No 2656353 Start */
--       display_balance_type VARCHAR2(10),
       display_balance_type VARCHAR2(15),
/* Bug No 2656353 End */
       year_category_type VARCHAR2(2)
     );

TYPE g_pos_ws_col_tbl_type IS TABLE OF g_pos_ws_col_rec_type
      INDEX BY BINARY_INTEGER;
g_pos_ws_cols g_pos_ws_col_tbl_type;


-- To store Percent of Salary Elements
TYPE g_ps_element_rec_type IS RECORD
     (
       pay_element_id            NUMBER,
       pay_element_period_type   VARCHAR2(10),
       pay_element_name          VARCHAR2(30),
       pay_element_set_id        NUMBER
     );

TYPE g_ps_elements_tbl_type IS TABLE OF g_ps_element_rec_type
      INDEX BY BINARY_INTEGER;

g_ps_elements g_ps_elements_tbl_type;

-- Store year amounts
TYPE g_year_amount_type IS RECORD
   ( amount NUMBER
   );
TYPE g_year_amount_tbl_type IS TABLE of g_year_amount_type
      INDEX BY BINARY_INTEGER;
g_year_amts g_year_amount_tbl_type;


-- To store the number of periods in each year, index by the year id
TYPE g_year_num_periods_type IS RECORD
   ( num_of_periods NUMBER
   );
TYPE g_year_num_periods_tbl_type IS TABLE of g_year_num_periods_type
      INDEX BY BINARY_INTEGER;
g_year_num_periods g_year_num_periods_tbl_type;

-- Store the account line IDs 1.. 12
TYPE g_acl_id_type IS RECORD
   ( acl_id NUMBER
   );
TYPE g_acl_id_tbl_type IS TABLE of g_acl_id_type
      INDEX BY BINARY_INTEGER;
g_acl_ids     g_acl_id_tbl_type;


-- Store the period amounts
TYPE g_period_amount_type IS RECORD
   ( amount NUMBER
   );
TYPE g_period_amount_tbl_type IS TABLE of g_period_amount_type
      INDEX BY BINARY_INTEGER;

g_wlbi_amounts         g_period_amount_tbl_type; --1.. 192 for inserting into wlbi
g_wal_period_amounts   g_period_amount_tbl_type; --1..12(upto 60)
g_ps_element_pct       g_period_amount_tbl_type; --1..12(upto 60)

FUNCTION Get_Next_Export_Seq RETURN NUMBER;


/* ----------------------------------------------------------------------- */
  -- Calls used by both Export and Import Procedures
  PROCEDURE Clear_WS_Cols;
  PROCEDURE Get_Calendar_Dates
   ( p_budget_calendar_id  IN NUMBER,
     p_calendar_start_date OUT  NOCOPY DATE,
     p_calendar_end_date   OUT  NOCOPY DATE,
     p_cy_end_date         OUT  NOCOPY DATE,
     p_pp_start_date       OUT  NOCOPY DATE
   );
/* ----------------------------------------------------------------------- */



/* ----------------------------------------------------------------------- */
  -- Start of comments
  --
  --    API name        : Move_To_Inter_CP
  --    Type            : Private
  --    Pre-reqs        : Move_To_Interface
  --    Parameters      :
  --    IN              :
  --                      p_export_name              IN   VARCHAR2   Required
  --                      p_worksheet_id             IN   NUMBER     Required
  --                      p_stage_id                 IN   NUMBER     Optional
  --                      p_export_worksheet_type    IN   VARCHAR2   Required
  --
  --    OUT  NOCOPY             :
  --                      errbuf                     OUT  NOCOPY  VARCHAR2   Required
  --                      retcode                    OUT  NOCOPY  NUMBER     Required
  --
  --    Version : Current version       1.0
  --              Initial version       1.0  ( 25-AUG-1998   SRawat )
  --
  --    Notes   : The concurrent execution file for the concurrent program
  --              'Move from PSB to Interface'.
  --
  -- End of comments

PROCEDURE Move_To_Inter_CP
(
  errbuf                      OUT  NOCOPY  VARCHAR2                        ,
  retcode                     OUT  NOCOPY  VARCHAR2                        ,
  --
  p_export_name               IN   VARCHAR2                        ,
  p_worksheet_id              IN   NUMBER                          ,
  p_stage_id                  IN   NUMBER  := FND_API.G_MISS_NUM   ,
  p_export_worksheet_type     IN   VARCHAR2
);

/* ----------------------------------------------------------------------- */



/* ----------------------------------------------------------------------- */
  -- Start of comments
  --
  --    API name        : Move_To_PSB_CP
  --    Type            : Private
  --    Pre-reqs        : Move_To_PSB
  --    Parameters      :
  --    IN              :
  --                      p_export_id                IN   NUMBER     Required
  --                      p_import_worksheet_type    IN   VARCHAR2   Required
  --                      p_amt_tolerance_value_type IN   VARCHAR2   Optional
  --                      p_amt_tolerance_value      IN   NUMBER     Optional
  --                      p_pct_tolerance_value_type IN   VARCHAR2   Optional
  --                      p_pct_tolerance_valuepe    IN   NUMBER     Optional
  --
  --    OUT  NOCOPY             :
  --                      errbuf                     OUT  NOCOPY  VARCHAR2   Required
  --                      retcode                    OUT  NOCOPY  NUMBER     Required
  --
  --    Version : Current version       1.0
  --              Initial version       1.0  ( 24-AUG-1998   SRawat )
  --
  --    Notes   : The concurrent execution file for the concurrent program
  --              'Move from PSB to interface'.
  --
  -- End of comments

PROCEDURE Move_To_PSB_CP
(
  errbuf                      OUT  NOCOPY  VARCHAR2                           ,
  retcode                     OUT  NOCOPY  VARCHAR2                           ,
  --
  p_export_id                 IN   NUMBER                             ,
  p_import_worksheet_type     IN   VARCHAR2                           ,
  p_amt_tolerance_value_type  IN   VARCHAR2 := FND_API.G_MISS_CHAR    ,
  p_amt_tolerance_value       IN   NUMBER   := FND_API.G_MISS_NUM     ,
  p_pct_tolerance_value_type  IN   VARCHAR2 := FND_API.G_MISS_CHAR    ,
  p_pct_tolerance_value       IN   NUMBER   := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */




/* ----------------------------------------------------------------------- */
  --    API name        : Del_Worksheet
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --    Parameters      :
  --    IN              : p_export_id                 IN   NUMBER   Required
  --    Version : Current version       1.0
  --              Initial version       1.0
  --              Created 10/20/1999 by Sivakumar Annamalai
  --
  --    Notes           : Deletes Worksheet from the Interface

PROCEDURE Del_Worksheet
(
  p_api_version               IN   NUMBER   ,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY  VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY  NUMBER   ,
  p_msg_data                  OUT  NOCOPY  VARCHAR2 ,
  --
  p_export_id                 IN   NUMBER
);


/* ----------------------------------------------------------------------- */
  --    API name        : Del_Worksheet_CP
  --    Type            : Private <Implementation>
  --    Pre-reqs        : Del_Worksheet
  --    Parameters      :
  --    IN              : p_export_id                 IN   NUMBER   Required
  --    Version : Current version       1.0
  --              Initial version       1.0
  --              Created 10/20/1999 by Sivakumar Annamalai
  --
  --    Notes           : Concurrent Program Definition procedure for
  --                      'Deletes Worksheet from the Interface'

PROCEDURE Del_Worksheet_CP
(
  errbuf                      OUT  NOCOPY  VARCHAR2 ,
  retcode                     OUT  NOCOPY  VARCHAR2 ,
  --
  p_export_id                 IN   NUMBER
);


END PSB_EXCEL_PVT;

 

/
