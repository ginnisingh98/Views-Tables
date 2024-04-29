--------------------------------------------------------
--  DDL for Package CSM_NOTES_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_NOTES_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmenots.pls 120.1 2005/07/25 00:15:58 trajasek noship $ */

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE NOTES_MAKE_DIRTY_I_FOREACHUSER(p_jtf_note_id IN NUMBER,
                                         p_error_msg     OUT NOCOPY    VARCHAR2,
                                         x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE NOTES_MAKE_DIRTY_U_FOREACHUSER(p_jtf_note_id IN NUMBER,
                                         p_error_msg     OUT NOCOPY    VARCHAR2,
                                         x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE NOTES_MAKE_DIRTY_I_GRP(p_sourceobjectcode IN VARCHAR2,
                                 p_sourceobjectid IN NUMBER,
                                 p_userid IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE NOTES_MAKE_DIRTY_D_GRP(p_sourceobjectcode IN VARCHAR2,
                                 p_sourceobjectid IN NUMBER,
                                 p_userid IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE OBJECT_MAPPINGS_ACC_PROCESSOR;

END CSM_NOTES_EVENT_PKG; -- Package spec


 

/
