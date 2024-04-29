--------------------------------------------------------
--  DDL for Package WF_DDL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_DDL" AUTHID CURRENT_USER as
  /* $Header: WFDDLS.pls 115.1 2002/10/28 19:05:52 rwunderl noship $ */

 PROCEDURE DropIndex (IndexName      IN    VARCHAR2,
                      Owner          IN    VARCHAR2,
                      IgnoreNotFound IN    BOOLEAN default FALSE);

 PROCEDURE TruncateTable (TableName      IN     VARCHAR2,
                          Owner          IN     VARCHAR2,
                          IgnoreNotFound IN     BOOLEAN default FALSE);

 end WF_DDL;


 

/
