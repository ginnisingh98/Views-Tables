--------------------------------------------------------
--  DDL for Package Body GL_BIS_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BIS_SECURITY_PKG" AS
/* $Header: gluoascb.pls 120.2 2003/04/30 02:38:41 djogg ship $ */

--
-- Global variables
--
RESPONSIBILITY_ID   FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;
SET_OF_BOOKS_ID     GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE;
--
-- PUBLIC FUNCTIONS
--

FUNCTION login_sob_id RETURN NUMBER IS
BEGIN
    return(SET_OF_BOOKS_ID);
END login_sob_id;


-- Initilaize global variables
BEGIN
    RESPONSIBILITY_ID := fnd_global.resp_id;
    SET_OF_BOOKS_ID   := to_number(fnd_profile.value_specific('GL_SET_OF_BKS_ID',
                                    null, RESPONSIBILITY_ID, 101));
END gl_bis_security_pkg;

/
