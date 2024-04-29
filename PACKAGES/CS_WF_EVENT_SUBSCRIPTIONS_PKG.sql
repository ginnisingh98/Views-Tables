--------------------------------------------------------
--  DDL for Package CS_WF_EVENT_SUBSCRIPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_WF_EVENT_SUBSCRIPTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: csxevtss.pls 120.0 2005/06/01 13:50:28 appldev noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date  		Comments
-- ---------   ---------	---------------------------------------
-- Enter package declarations as shown below
--
-- RMANABAT    04-OCT-04	Added CS_SR_SendNtf_To_NonFS_Task()  for Task
--				restriction project.

  FUNCTION CS_SR_Verify_All(p_subscription_guid in raw,
                            p_event in out nocopy WF_EVENT_T) RETURN varchar2;

  FUNCTION CS_SR_SendNtf_To_NonFS_Task(p_subscription_guid in raw,
                                     p_event in out nocopy WF_EVENT_T) RETURN varchar2;

END; -- Package Specification CS_WF_EVENT_SUBSCRIPTIONS_PKG

 

/
