--------------------------------------------------------
--  DDL for Package WSH_SHIP_CONFIRM_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIP_CONFIRM_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHSCTHS.pls 120.1 2005/07/29 19:23:27 wrudge noship $ */

TYPE ship_confirm_rule_rectype IS RECORD (
 SHIP_CONFIRM_RULE_ID                     NUMBER,
 EFFECTIVE_START_DATE                     DATE,
 NAME                                     VARCHAR2(30),
 EFFECTIVE_END_DATE                       DATE,
 ACTION_FLAG                              VARCHAR2(1),
 STAGE_DEL_FLAG                           VARCHAR2(1),
 SHIP_METHOD_DEFAULT_FLAG                 VARCHAR2(1),
 SHIP_METHOD_CODE                         VARCHAR2(30),
 AC_ACTUAL_DEP_DATE_DEFAULT               VARCHAR2(30),
 AC_INTRANSIT_FLAG                        VARCHAR2(1),
 AC_CLOSE_TRIP_FLAG                       VARCHAR2(1),
 AC_BOL_FLAG                              VARCHAR2(1),
 AC_DEFER_INTERFACE_FLAG                  VARCHAR2(1),
 MC_INTRANSIT_FLAG                        VARCHAR2(1),
 MC_CLOSE_TRIP_FLAG                       VARCHAR2(1),
 MC_DEFER_INTERFACE_FLAG                  VARCHAR2(1),
 MC_BOL_FLAG		                  VARCHAR2(1),
 REPORT_SET_ID                            NUMBER,
 SEND_945_FLAG                            VARCHAR2(1),
 CREATION_DATE                            DATE,
 CREATED_BY                               NUMBER,
 LAST_UPDATED_BY                          NUMBER,
 LAST_UPDATE_DATE                         DATE);


PROCEDURE Insert_Row (
  p_ship_confirm_rule_info    IN  ship_confirm_rule_rectype,
  x_rule_id                   OUT NOCOPY NUMBER,
  x_row_id                    OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE Update_Row (
  p_ship_confirm_rule_info    IN  ship_confirm_rule_rectype,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE Lock_Row(
    p_rowid                  IN   VARCHAR2,
    p_ship_confirm_rule_info IN   ship_confirm_rule_rectype) ;

PROCEDURE Delete_Row(
        p_rowid         IN  VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2);

END WSH_SHIP_CONFIRM_RULES_PVT;

 

/
