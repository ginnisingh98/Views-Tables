--------------------------------------------------------
--  DDL for Package AS_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: asxpstas.pls 115.3 2003/01/28 23:13:28 geliu ship $ */


-- Start of Comments
--
-- Record Type Name : STATUS_Rec_Type
-- Type             : Global
-- Notes            :
-- The record type has default values as g_miss values and is used as
-- an input parameter for both the procedures create and update status code
--
-- End of Comments

TYPE STATUS_Rec_Type IS RECORD
(
STATUS_CODE                    VARCHAR2(30),
LAST_UPDATED_BY                NUMBER            DEFAULT  FND_API.G_MISS_NUM,
LAST_UPDATE_DATE               DATE              DEFAULT  FND_API.G_MISS_DATE,
CREATION_DATE                  DATE              DEFAULT  FND_API.G_MISS_DATE,
CREATED_BY                     NUMBER            DEFAULT  FND_API.G_MISS_NUM,
LAST_UPDATE_LOGIN              NUMBER            DEFAULT  FND_API.G_MISS_NUM,
ENABLED_FLAG                   VARCHAR2(1)       DEFAULT  FND_API.G_MISS_CHAR,
LEAD_FLAG                      VARCHAR2(1)       DEFAULT  FND_API.G_MISS_CHAR,
OPP_FLAG                       VARCHAR2(1)       DEFAULT  FND_API.G_MISS_CHAR,
OPP_OPEN_STATUS_FLAG           VARCHAR2(1)       DEFAULT  FND_API.G_MISS_CHAR,
OPP_DECISION_DATE_FLAG         VARCHAR2(1)       DEFAULT  FND_API.G_MISS_CHAR,
STATUS_RANK                    NUMBER            DEFAULT  FND_API.G_MISS_NUM,
FORECAST_ROLLUP_FLAG           VARCHAR2(1)       DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE_CATEGORY             VARCHAR2(30)      DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE1                     VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE2                     VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE3                     VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE4                     VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE5                     VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE6                     VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE7                     VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE8                     VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE9                     VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE10                    VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE11                    VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE12                    VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE13                    VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE14                    VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
ATTRIBUTE15                    VARCHAR2(150)     DEFAULT  FND_API.G_MISS_CHAR,
MEANING                        VARCHAR2(240)     DEFAULT  FND_API.G_MISS_CHAR,
DESCRIPTION                    VARCHAR2(240)     DEFAULT  FND_API.G_MISS_CHAR,
WIN_LOSS_INDICATOR             VARCHAR2(1)       DEFAULT  FND_API.G_MISS_CHAR);

G_MISS_STATUS_REC AS_STATUS_PUB.STATUS_Rec_Type;

-- Start of Comments
--
-- API Name     : create_status
-- Type         : Public
-- Parameters   : Standard API Parameters and the p_status_rec
-- record type parameter are the parameters for this procedure.
--
-- End of Comments

PROCEDURE create_status (
    p_api_version_number      IN    NUMBER,
    p_init_msg_list           IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                  IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level        IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
    p_status_rec              IN    STATUS_Rec_Type DEFAULT G_MISS_STATUS_REC,
    x_return_status           OUT   VARCHAR2,
    x_msg_count               OUT   NUMBER,
    x_msg_data                OUT   VARCHAR2);

-- Start of Comments
--
-- API Name     : update_status
-- Type         : Public
-- Parameters   : Standard API Parameters and the p_status_rec
-- record type parameter are the parameters for this procedure.
--
-- End of Comments

PROCEDURE update_status (
    p_api_version_number   IN     NUMBER,
    p_init_msg_list        IN     VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit               IN     VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level     IN     NUMBER   DEFAULT fnd_api.g_valid_level_full,
    p_status_rec           IN     STATUS_Rec_Type DEFAULT G_MISS_STATUS_REC,
    x_return_status        OUT    VARCHAR2,
    x_msg_count            OUT    NUMBER,
    x_msg_data             OUT    VARCHAR2);

END as_status_pub;

 

/
