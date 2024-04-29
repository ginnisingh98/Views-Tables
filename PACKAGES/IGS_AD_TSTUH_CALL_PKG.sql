--------------------------------------------------------
--  DDL for Package IGS_AD_TSTUH_CALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_TSTUH_CALL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADA6S.pls 115.4 2002/11/28 21:48:11 nsidana ship $ */

PROCEDURE call_user_hook
( p_person_id		IN  NUMBER,
  p_session_id		OUT NOCOPY NUMBER
);
END IGS_AD_TSTUH_CALL_PKG;

 

/
