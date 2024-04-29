--------------------------------------------------------
--  DDL for Package Body GL_AUTO_ALLOC_BHD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTO_ALLOC_BHD_PKG" as
/* $Header: glialhdb.pls 120.3 2005/05/05 00:58:57 kvora ship $ */

  --
  -- PUBLIC FUNCTIONS
  --
  PROCEDURE populate_fields(p_request_id IN NUMBER, s_number IN NUMBER,
  request_id IN OUT NOCOPY NUMBER) IS
  CURSOR c_request IS
      SELECT request_id
      FROM   GL_AUTO_ALLOC_BAT_HIST_DET
      WHERE  parent_request_id = p_request_id
      AND    step_number = s_number;
  BEGIN
    OPEN c_request;
    FETCH c_request INTO request_id;
    CLOSE c_request;

  END populate_fields;

END GL_AUTO_ALLOC_BHD_PKG;

/
