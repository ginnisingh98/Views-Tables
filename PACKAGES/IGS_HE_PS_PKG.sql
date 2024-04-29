--------------------------------------------------------
--  DDL for Package IGS_HE_PS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_PS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE15S.pls 115.2 2002/11/29 00:42:43 nsidana noship $ */

PROCEDURE COPY_PROG_VERSION(
     p_old_course_cd IN VARCHAR2,
     p_old_version_number IN NUMBER,
     p_new_course_cd IN VARCHAR2,
     p_new_version_number IN NUMBER,
     p_message_name OUT NOCOPY VARCHAR2,
     p_status OUT NOCOPY NUMBER);

END IGS_HE_PS_PKG;


 

/
