--------------------------------------------------------
--  DDL for Package FTP_BR_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTP_BR_ADJUSTMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: ftpadjs.pls 120.0.12000000.1 2007/07/27 12:08:18 shishank noship $ */

PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
);


PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

END ftp_br_adjustment_pvt ;


 

/
