--------------------------------------------------------
--  DDL for Package AST_MVIEW_REFRESH_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_MVIEW_REFRESH_CUHK" AUTHID CURRENT_USER AS
/* $Header: astchmvs.pls 115.1 2002/12/04 21:49:12 qliu ship $ */


/*============================================================================
   This package is created for user to resolve the fine grain access policy
   conflicts with materialized view (ORA-30372).

   In order for the materialized view to work correctly, any fine grain
   access control procedure in effect for the query must return a null policy
   when the materialized view is being created or refreshed.
 ============================================================================*/


PROCEDURE MView_Refresh_Pre(
   p_mview_name		   IN VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_data              OUT NOCOPY VARCHAR2
);


PROCEDURE MView_Refresh_Post(
   p_mview_name		   IN VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_data              OUT NOCOPY VARCHAR2
);

END AST_MVIEW_REFRESH_CUHK;


 

/
