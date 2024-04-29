--------------------------------------------------------
--  DDL for Package PAY_BANK_BRANCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BANK_BRANCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: pybbr01t.pkh 115.3 2004/08/20 10:49:59 arashid noship $ */
-----------------------------------------------------------
-- The following procedures deal with the maintenance of --
-- PAY_BANK_BRANCHES.                                    --
-----------------------------------------------------------
------------------------------< INSERT_ROW >--------------------------------
-- Name
--   INSERT_ROW
--
-- Notes
--   An exception is raised upon failure
--
PROCEDURE INSERT_ROW
(P_BRANCH_CODE           IN     VARCHAR2
,P_LEGISLATION_CODE      IN     VARCHAR2
,P_BANK_CODE             IN     VARCHAR2
,P_BRANCH                IN     VARCHAR2
,P_LONG_BRANCH           IN     VARCHAR2 DEFAULT NULL
,P_EXTRA_INFORMATION1    IN     VARCHAR2 DEFAULT NULL
,P_EXTRA_INFORMATION2    IN     VARCHAR2 DEFAULT NULL
,P_EXTRA_INFORMATION3    IN     VARCHAR2 DEFAULT NULL
,P_EXTRA_INFORMATION4    IN     VARCHAR2 DEFAULT NULL
,P_EXTRA_INFORMATION5    IN     VARCHAR2 DEFAULT NULL
,P_ENABLED_FLAG          IN     VARCHAR2 DEFAULT 'Y'
,P_START_DATE_ACTIVE     IN     DATE     DEFAULT HR_API.G_SOT
,P_END_DATE_ACTIVE       IN     DATE     DEFAULT HR_API.G_EOT
);
-------------------------------< LOCK_ROW >--------------------------------
-- Name
--   LOCK_ROW
--
-- Notes
--   An exception is raised upon failure.
--
PROCEDURE LOCK_ROW
(P_BRANCH_CODE      IN VARCHAR2
,P_LEGISLATION_CODE IN VARCHAR2
);
------------------------------< UPDATE_ROW >-------------------------------
--
-- Name
--   UPDATE_ROW
--
-- Notes
--   An exception is raised upon failure.
--
PROCEDURE UPDATE_ROW
(P_BRANCH_CODE        IN VARCHAR2
,P_LEGISLATION_CODE   IN VARCHAR2
,P_BANK_CODE          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_BRANCH             IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_LONG_BRANCH        IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_EXTRA_INFORMATION1 IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_EXTRA_INFORMATION2 IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_EXTRA_INFORMATION3 IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_EXTRA_INFORMATION4 IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_EXTRA_INFORMATION5 IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_ENABLED_FLAG       IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_START_DATE_ACTIVE  IN DATE     DEFAULT HR_API.G_DATE
,P_END_DATE_ACTIVE    IN DATE     DEFAULT HR_API.G_DATE
);
------------------------------< DELETE_ROW >-------------------------------
--
-- Name
--   DELETE_ROW
--
-- Notes
--   An exception is raised upon failure.
--
PROCEDURE DELETE_ROW
(P_BRANCH_CODE      IN VARCHAR2
,P_LEGISLATION_CODE IN VARCHAR2
);
----------------------------------------------------------
-- GB legislation covers for INSERT_ROW and UPDATE_ROW. --
----------------------------------------------------------
----------------------------< INSERT_GB_ROW >------------------------------
-- Name
--   INSERT_GB_ROW
--
-- Description
--   GB legislation cover for INSERT_ROW.
--
-- Notes
--   P_SORT_CODE is 0-left padded on output.
--   P_BUILDING_SOCIETY_ACCT is ignored.
--   The converted values are passed to INSERT_ROW.
--   An exception is raised upon failure.
--
PROCEDURE INSERT_GB_ROW
(P_SORT_CODE             IN OUT NOCOPY VARCHAR2
,P_BANK_CODE             IN            VARCHAR2
,P_BRANCH                IN            VARCHAR2
,P_LONG_BRANCH           IN            VARCHAR2 DEFAULT NULL
,P_BUILDING_SOCIETY_ACCT IN OUT NOCOPY VARCHAR2
,P_ENABLED_FLAG          IN            VARCHAR2 DEFAULT 'Y'
,P_START_DATE_ACTIVE     IN            DATE     DEFAULT HR_API.G_SOT
,P_END_DATE_ACTIVE       IN            DATE     DEFAULT HR_API.G_EOT
);
----------------------------< UPDATE_GB_ROW >------------------------------
-- Name
--   UPDATE_GB_ROW
--
-- Description
--   GB legislation cover for UPDATE_ROW.
--
-- Notes
--   The HR_API constants (HR_API.G_VARCHAR2 or HR_API.G_DATE) are
--   treated as the 'no-change' values.
--   P_BUILDING_SOCIETY_ACCT is ignored.
--   The converted value is passed to UPDATE_ROW.
--   An exception is raised upon failure.
--
PROCEDURE UPDATE_GB_ROW
(P_SORT_CODE             IN            VARCHAR2
,P_BRANCH                IN            VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_LONG_BRANCH           IN            VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_BUILDING_SOCIETY_ACCT IN OUT NOCOPY VARCHAR2
,P_ENABLED_FLAG          IN            VARCHAR2 DEFAULT HR_API.G_VARCHAR2
,P_START_DATE_ACTIVE     IN            DATE     DEFAULT HR_API.G_DATE
,P_END_DATE_ACTIVE       IN            DATE     DEFAULT HR_API.G_DATE
);
-------------------------------------------------------------
-- The following procedures are for self-service and other --
-- forms that deal with the bank accounts.                 --
-------------------------------------------------------------
------------------------< DISPLAY_TO_GB_ACCOUNT >--------------------------
-- Name
--  DISPLAY_TO_GB_ACCOUNT
--
-- Description
--   If necessary creates a new PAY_EXTERNAL_ACCOUNTS row
--   based upon changes to information displayed on the screen.
--
--   An exception is raised upon failure.
--
--   Upon success a new row may be created in PAY_EXTERNAL_ACCOUNTS and
--   P_EXTERNAL_ACCOUNT_ID, and P_OBJECT_VERSION_NUMBER are updated for
--   this new row. These parameters are not updated if a new account row
--   was not created.
--
-- Notes
--   If ACCOUNT_NAME, ACCOUNT_NUMBER or SORT_CODE differ from
--   the values in PAY_EXTERNAL_ACCOUNTS then a new row is
--   created using information from PAY_BANK_BRANCHES and the
--   supplied data.
--
PROCEDURE DISPLAY_TO_GB_ACCOUNT
(P_EXTERNAL_ACCOUNT_ID   IN OUT NOCOPY NUMBER
,P_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER
,P_BUSINESS_GROUP_ID     IN            NUMBER
,P_EFFECTIVE_DATE        IN            DATE
,P_ACCOUNT_NAME          IN            VARCHAR2
,P_ACCOUNT_NUMBER        IN            VARCHAR2
,P_SORT_CODE             IN            VARCHAR2
,P_BUILDING_SOCIETY_ACCT IN            VARCHAR2 DEFAULT NULL
,P_MULTI_MESSAGE         IN            BOOLEAN  DEFAULT FALSE
,P_RETURN_STATUS            OUT NOCOPY VARCHAR2
,P_MSG_COUNT                OUT NOCOPY NUMBER
,P_MSG_DATA                 OUT NOCOPY VARCHAR2
);
--
END PAY_BANK_BRANCHES_PKG;

 

/
