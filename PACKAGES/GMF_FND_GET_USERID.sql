--------------------------------------------------------
--  DDL for Package GMF_FND_GET_USERID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_FND_GET_USERID" AUTHID CURRENT_USER AS
/* $Header: gmfusris.pls 115.1 2002/11/11 00:46:33 rseshadr ship $ */
  PROCEDURE proc_fnd_get_user_id(
          start_date  in out  NOCOPY date,
          end_date    in out  NOCOPY date,
          usr_name            varchar2,
          user_id     out   NOCOPY number,
          row_to_fetch in out NOCOPY number,
          error_status out   NOCOPY number);
END GMF_FND_GET_USERID;

 

/
