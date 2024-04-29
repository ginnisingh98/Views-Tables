--------------------------------------------------------
--  DDL for Package IEX_FILTER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_FILTER_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpfils.pls 120.3.12010000.4 2010/06/02 11:19:25 barathsr ship $ */

  TYPE FILTER_REC_TYPE IS RECORD(
    OBJECT_FILTER_ID       NUMBER        := FND_API.G_MISS_NUM,
    OBJECT_FILTER_TYPE     VARCHAR2(240)  := FND_API.G_MISS_CHAR,
    OBJECT_FILTER_NAME     VARCHAR2(240)  := FND_API.G_MISS_CHAR,
    OBJECT_ID              NUMBER        := FND_API.G_MISS_NUM,
    SELECT_COLUMN          VARCHAR2(30)  := FND_API.G_MISS_CHAR,
    ENTITY_NAME            VARCHAR2(30)  := FND_API.G_MISS_CHAR,
    ACTIVE_FLAG            VARCHAR2(1)   := FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER  NUMBER        := FND_API.G_MISS_NUM,
    PROGRAM_ID             NUMBER        := FND_API.G_MISS_NUM,
    REQUEST_ID             NUMBER        := FND_API.G_MISS_NUM,
    PROGRAM_APPLICATION_ID NUMBER        := FND_API.G_MISS_NUM,
    PROGRAM_UPDATE_DATE    DATE          := FND_API.G_MISS_DATE,
    CREATION_DATE          DATE          := FND_API.G_MISS_DATE,
    CREATED_BY             NUMBER        := FND_API.G_MISS_NUM,
    LAST_UPDATE_DATE       DATE          := FND_API.G_MISS_DATE,
    LAST_UPDATED_BY        NUMBER        := FND_API.G_MISS_NUM,
    LAST_UPDATE_LOGIN      NUMBER        := FND_API.G_MISS_NUM);


  G_MISS_FILTER_REC          IEX_FILTER_PUB.FILTER_REC_TYPE;

type Universe_IDS is table of number
    index by binary_integer;

/*
|| Overview: this function will return a dynamic SQL statement to
|| execute as the universe of  objects to score for a particular
|| scoring engine
||
|| Parameter: p_object_id   Scoring_Engine or Strategy Engine attached to the universe
||            p_object_type = EITHER SCORE OR STRATEGY OR AGING
||
|| Return value: select statement for the Universe
||
|| Source Tables: IEX_OBJECT_FILTERS
||
|| Target Tables: none
||
|| Creation date:  01/09/02 3:38:PM
||
|| Major Modifications: when            who                       what
||                      01/09/02        raverma             created
*/
function buildUniverse(p_object_id IN NUMBER
                      ,p_query_obj_id in varchar2 default null   --Added for Bug 8933776 21-Dec-2009 barathsr
		      ,p_limit_rows in number default null   --Added for Bug 8933776 21-Dec-2009 barathsr
                      ,p_object_type IN VARCHAR2
                      ,p_last_object_scored in out nocopy number
                      ,x_end_of_universe out nocopy  boolean)
         return IEX_FILTER_PUB.UNIVERSE_IDS;

function buildsql(p_object_id IN NUMBER, p_object_type IN VARCHAR2, p_query_obj_id in varchar2 default null   --Added for Bug 9670348 27-May-2009 barathsr
		      ,p_limit_rows in number default null)   --Added for Bug 9670348 27-May-2009 barathsr
		      return varchar2; -- added for bug 9387044

Procedure Validate_FILTER(P_Init_Msg_List              IN   VARCHAR2 := FND_API.G_FALSE,
                          P_FILTER_rec                 IN   IEX_FILTER_PUB.FILTER_REC_TYPE,
                          X_Dup_Status                 OUT NOCOPY  VARCHAR2,
                          X_Return_Status              OUT NOCOPY  VARCHAR2,
                          X_Msg_Count                  OUT NOCOPY  NUMBER,
                          X_Msg_Data                   OUT NOCOPY  VARCHAR2);

Procedure Create_OBJECT_FILTER
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
            p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
            P_FILTER_REC              IN IEX_FILTER_PUB.FILTER_REC_TYPE  := G_MISS_FILTER_REC,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            X_FILTER_ID               OUT NOCOPY NUMBER);


Procedure Update_OBJECT_FILTER
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
            p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
            P_FILTER_REC              IN IEX_FILTER_PUB.FILTER_REC_TYPE  := G_MISS_FILTER_REC,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);



Procedure Delete_OBJECT_FILTER
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
            p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
            P_OBJECT_FILTER_ID        IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);



END IEX_FILTER_PUB;

/
