--------------------------------------------------------
--  DDL for Package GMS_AWARD_MANAGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AWARD_MANAGER_PKG" AUTHID CURRENT_USER as
-- $Header: gmsawams.pls 120.1 2005/07/26 14:20:30 appldev ship $

PROCEDURE insert_award_manager_id
(
 x_AWARD_ID in number ,
 x_qk_award_manager_id in number,
 x_start_date_active in date
);
END gms_AWARD_MANAGER_PKG;

 

/
