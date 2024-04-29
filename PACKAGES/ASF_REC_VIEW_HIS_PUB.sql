--------------------------------------------------------
--  DDL for Package ASF_REC_VIEW_HIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASF_REC_VIEW_HIS_PUB" AUTHID CURRENT_USER AS
/* $Header: asffrvhs.pls 115.1 2002/03/25 17:17:00 pkm ship  $ */

  procedure Update_Entry(p_object_code  IN  varchar2,
                         p_object_id    IN  number,
                         x_return_status OUT varchar2,
                         x_error_message OUT varchar2);
end ASF_REC_VIEW_HIS_PUB;

 

/
