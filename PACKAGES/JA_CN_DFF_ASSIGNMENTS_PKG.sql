--------------------------------------------------------
--  DDL for Package JA_CN_DFF_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_DFF_ASSIGNMENTS_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNDFAS.pls 120.0.12000000.1 2007/08/13 14:09:31 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNDFAS.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|      This package provides table handers for                          |
  --|      table JA_CN_DFF_ASSIGNMENTS, these handlers                      |
  --|      will be called by 'DFF Assignments' form to operate data in table|
  --|      JA_CN_DFF_ASSIGNMENTS                                            |
  --|                                                                       |
  --| HISTORY                                                               |
  --|     2006/03/01 Jackey Li       Created                                |
  --+======================================================================*/

  --Declare global variable for package name
  --G_MODULE_PREFIX VARCHAR2(50) :='ja.pl/sql.JA_CN_DFF_ASSIGNMENTS_PKG';

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Insert_Row                        Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is to insert data that are passed in by parameters into
  --    table JA_CN_DFF_ASSIGNMENTS to create a new record
  --
  --  PARAMETERS:
  --      In:  p_application_id                 Application ID
  --           p_dff_name                       Descriptive Flexfield Name
  --           p_dff_title_code                 DFF title lookup code
  --           p_context_code                   DFF context
  --           p_attribute_column               DFF column
  --           p_creation_date                  Creation date
  --           p_created_by                     Identifier of user that creates
  --                                             the record
  --           p_last_update_date               Last update date of the record
  --           p_last_updated_by                Last update by
  --           p_last_update_login              Last update login
  --
  --   In Out: p_row_id                         Row id of a table record
  --
  --
  --  DESIGN REFERENCES:
  --    CNAO_DFF_ASSIGNMENT_FORM_TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           01-MAR-2006  Jackey Li  created
  --           16-MAy-2007  yanbo liu  changed
  --           add chart_of_accounts_id column.
  --===========================================================================
  PROCEDURE Insert_Row(p_row_id            IN OUT NOCOPY VARCHAR2
                      ,P_application_id    IN NUMBER
                      ,p_dff_name          IN VARCHAR2
                      ,p_dff_title_code    IN VARCHAR2
                      ,p_context_code      IN VARCHAR2
                      ,p_attribute_column  IN VARCHAR2
                      ,p_creation_date     IN DATE
                      ,p_created_by        IN NUMBER
                      ,p_last_update_date  IN DATE
                      ,p_last_updated_by   IN NUMBER
                      ,p_last_update_login IN NUMBER
                      ,p_chart_of_accounts_id In NUMBER
                      );

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Update_Row                        Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to update data in table JA_CN_DFF_ASSIGNMENTS
  --    according to parameters passed in
  --
  --  PARAMETERS:
  --      In:  p_application_id                 Application ID
  --           p_dff_name                       Descriptive Flexfield Name
  --           p_dff_title_code                 DFF title lookup code
  --           p_context_code                   DFF context
  --           p_attribute_column               DFF column
  --           p_creation_date                  Creation date
  --           p_created_by                     Identifier of user that creates
  --                                             the record
  --           p_last_update_date               Last update date of the record
  --           p_last_updated_by                Last update by
  --           p_last_update_login              Last update login
  --
  --  In Out:  p_row_id                         Row id of a table record
  --
  --
  --  DESIGN REFERENCES:
  --    CNAO_DFF_ASSIGNMENT_FORM_TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           01-MAR-2006  Jackey Li  created
  --           16-MAy-2007  yanbo liu  changed
  --           add chart_of_accounts_id column.
  --===========================================================================
  PROCEDURE Update_Row(p_row_id            IN OUT NOCOPY VARCHAR2
                      ,P_application_id    IN NUMBER
                      ,p_dff_name          IN VARCHAR2
                      ,p_dff_title_code    IN VARCHAR2
                      ,p_context_code      IN VARCHAR2
                      ,p_attribute_column  IN VARCHAR2
                      ,p_creation_date     IN DATE
                      ,p_created_by        IN NUMBER
                      ,p_last_update_date  IN DATE
                      ,p_last_updated_by   IN NUMBER
                      ,p_last_update_login IN NUMBER
                      ,p_chart_of_accounts_id In NUMBER
                      );

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Lock_Row                          Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to implement lock on row level on table
  --    JA_CN_DFF_ASSIGNMENTS
  --
  --  PARAMETERS:
  --      In:  p_application_id                 Application ID
  --           p_dff_name                       Descriptive Flexfield Name
  --           p_dff_title_code                 DFF title lookup code
  --           p_context_code                   DFF context
  --           p_attribute_column               DFF column
  --           p_creation_date                  Creation date
  --           p_created_by                     Identifier of user that creates
  --                                             the record
  --           p_last_update_date               Last update date of the record
  --           p_last_updated_by                Last update by
  --           p_last_update_login              Last update login
  --
  --  In Out:  p_row_id                         Row id of a table record
  --
  --
  --  DESIGN REFERENCES:
  --    CNAO_DFF_ASSIGNMENT_FORM_TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           01-MAR-2006  Jackey Li  created
  --           16-MAy-2007  yanbo liu  changed
  --           add chart_of_accounts_id column.
  --===========================================================================
  PROCEDURE Lock_Row(p_row_id            IN OUT NOCOPY VARCHAR2
                    ,P_application_id    IN NUMBER
                    ,p_dff_name          IN VARCHAR2
                    ,p_dff_title_code    IN VARCHAR2
                    ,p_context_code      IN VARCHAR2
                    ,p_attribute_column  IN VARCHAR2
                    ,p_creation_date     IN DATE
                    ,p_created_by        IN NUMBER
                    ,p_last_update_date  IN DATE
                    ,p_last_updated_by   IN NUMBER
                    ,p_last_update_login IN NUMBER
                    ,p_chart_of_accounts_id In NUMBER
                    );

END JA_CN_DFF_ASSIGNMENTS_PKG;

 

/
