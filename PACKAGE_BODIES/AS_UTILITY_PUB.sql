--------------------------------------------------------
--  DDL for Package Body AS_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_UTILITY_PUB" as
/* $Header: asxputlb.pls 120.1 2005/06/05 22:52:35 appldev  $ */

-- Start of Comments
--
-- NAME
--   AS_UTILITY_PUB
--
-- PURPOSE
--   This package is a public utility API developed from Sales Core group
--
-- NOTES
--
--
-- HISTORY

--   06/27/00   SOLIN                CREATED
--
--
-- End of Comments

G_PKG_NAME    CONSTANT VARCHAR2(30):='AS_UTILITY_PUB';
G_FILE_NAME   CONSTANT VARCHAR2(12):='asxputlb.pls';


PROCEDURE Get_Messages(
    p_message_count     IN     NUMBER,
    x_msgs              OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS
BEGIN
     AS_UTILITY_PVT.Get_Messages(
         p_message_count => p_message_count,
         x_msgs          => x_msgs);
END Get_Messages;


END AS_UTILITY_PUB;

/
