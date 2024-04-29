--------------------------------------------------------
--  DDL for Package AS_IMPORT_SL_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_IMPORT_SL_CUHK" AUTHID CURRENT_USER AS
/* $Header: asxcslis.pls 120.1 2006/02/09 14:52:44 solin noship $ */

-- Start of Comments
-- Package Name     : AS_IMPORT_SL_CUHK
--
-- Purpose          : While importing leads, the lead import program does not
--                    verify whether such a lead exist in Oracle Sales or not.
--                    i.e. it will create duplicate entities in Oracle Sales
--                    if the lead already exist.
--                    If user want to implement custom lead existence checking
--                    logic, then write a package body for this spec.
--
-- NOTE             : User's lead existence checking should check if lead
--                    is duplicate or not and base on the returned value, Oracle
--                    lead import program will either create a new lead or skip
--                    that particular lead import record. If the record is
--                    skipped then no lead will be created and load_status
--                    of that lead import record will be set to 'DUPLICATE'.
--
--                    Please do not 'commit' in the package body. Once the
--                    transaction is completed, Oracle Application code will
--                    issue a commit.
--
--                    This user hook will be called in lead import program.
--                    The calling package: AS_IMPORT_SL_PVT.Is_Duplicate_Lead
--
-- History          :
--       08/14/2001   SOLIN   Created
-- End of Comments

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC CONSTANTS
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC DATATYPES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC VARIABLES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/

-- Start of Comments
--
--   API name   : Is_Duplicate_Lead_Pre
--   Parameters :
--   IN         :
--       p_api_version_number: For 11i Oracle Sales application, this is 2.0.
--       p_init_msg_list     : Initialize message stack or not. It's
--                             FND_API.G_FALSE by default.
--       p_validation_level  : Validation level for pass-in values.
--                             It's FND_API.G_VALID_LEVEL_FULL by default.
--       p_commit            : Whether commit the whole API at the end of API.
--                             It's FND_API.G_FALSE by default.
--
--                             The above four parameters are standard input.
--       p_import_interface_id:
--                             This is the import interface identifier.
--                             Pass into import_interface_id ofthe lead import
--                             record for which you want to perform the lead
--                             existence checking.
--   OUT        :
--       x_duplicate_flag    :
--                             If this flag is 'Y', means this lead import
--                             record is duplicate and do not import the lead;
--                             'N' means such a lead does not exist and lead
--                             will be imported.
--       x_return_status     :
--                             The return status. If your code completes
--                             successfully, then FND_API.G_RET_STS_SUCCESS
--                             should be returned; if you get an expected error,
--                             then return FND_API.G_RET_STS_ERROR; otherwise
--                             return FND_API.G_RET_STS_UNEXP_ERROR.
--       x_msg_count         :
--                             The message count.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--       x_msg_data          :
--                             The messages.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--
--                             The above three parameters are standard output
--                             parameters.
--
--
PROCEDURE Is_Duplicate_Lead_Pre(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_import_interface_id   IN  NUMBER,
    x_duplicate_flag        OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2);

END AS_IMPORT_SL_CUHK;


 

/
