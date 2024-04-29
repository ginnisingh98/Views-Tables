--------------------------------------------------------
--  DDL for Package JTF_DIAGNOSTIC_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DIAGNOSTIC_SYNC" AUTHID CURRENT_USER as
  /* $Header: jtfdiagsyncs.pls 115.1 2003/07/30 00:47:39 navkumar noship $ */
  PROCEDURE diagSyncAll;
  FUNCTION diagsync(	key1 JTF_DIAGNOSTIC_CMAP.appName%TYPE,
			key2 JTF_DIAGNOSTIC_CMAP.groupName%TYPE,
			key3 JTF_DIAGNOSTIC_CMAP.testClassName%TYPE,
			classList JTF_DIAGNOSTIC_LOG.versions%TYPE) RETURN INTEGER;
  FUNCTION diagentry(	key1 JTF_DIAGNOSTIC_CMAP.appName%TYPE,
			key2 JTF_DIAGNOSTIC_CMAP.groupName%TYPE,
			key3 JTF_DIAGNOSTIC_CMAP.testClassName%TYPE,
			className JTF_DIAGNOSTIC_CMAP.className%TYPE) RETURN INTEGER;
end jtf_diagnostic_sync;

 

/
