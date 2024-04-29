--------------------------------------------------------
--  DDL for Package Body MRP_FLOW_SCHEDULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_FLOW_SCHEDULE_PUB" AS
/* $Header: MRPPWFSB.pls 120.1.12010000.2 2008/08/20 19:26:14 adasa ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Flow_Schedule_PUB';

--  Forward declaration of Procedure Id_To_Value
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/
PROCEDURE Id_To_Value
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_val_rec         OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type
);

--  Forward declaration of procedure Value_To_Id
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/
PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_flow_schedule_val_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type
,   x_flow_schedule_rec             OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

--  Start of Comments
--  API name    Process_Flow_Schedule
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Flow_Schedule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  Flow_Schedule_Rec_Type :=
                                        G_MISS_FLOW_SCHEDULE_REC
,   p_flow_schedule_val_rec         IN  Flow_Schedule_Val_Rec_Type :=
                                        G_MISS_FLOW_SCHEDULE_VAL_REC
,   x_flow_schedule_rec             OUT NOCOPY Flow_Schedule_Rec_Type
,   x_flow_schedule_val_rec         OUT NOCOPY Flow_Schedule_Val_Rec_Type
,   p_explode_bom		    IN	VARCHAR2 := 'N'
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Flow_Schedule';
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_old_flow_schedule_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_flow_schedule_val_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type;
l_x_flow_schedule_val_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type;
l_error_msg		VARCHAR2(2000);
l_error_code		NUMBER;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*bug 5292986 - set the operation unit so project/task can be validated correctly */
    fnd_profile.PUT('MFG_ORGANIZATION_ID', p_flow_schedule_rec.organization_id);

    MRP_Flow_Schedule_PVT.PUB_Flow_Sched_Rec_To_PVT(p_flow_schedule_rec,l_p_flow_schedule_rec);
    MRP_Flow_Schedule_PVT.PUB_Flow_Sched_Val_Rec_To_PVT(p_flow_schedule_val_rec,l_p_flow_schedule_val_rec);

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_flow_schedule_rec           => l_p_flow_schedule_rec
    ,   p_flow_schedule_val_rec       => l_p_flow_schedule_val_rec
    ,   x_flow_schedule_rec           => l_flow_schedule_rec
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call MRP_Flow_Schedule_PVT.Process_Flow_Schedule

    MRP_Flow_Schedule_PVT.Process_Flow_Schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_flow_schedule_rec           => l_flow_schedule_rec
    ,   p_old_flow_schedule_rec       => l_p_old_flow_schedule_rec
    ,   x_flow_schedule_rec           => l_flow_schedule_rec
    ,   p_explode_bom		      => 'Y'
    );

    --  Load Id OUT parameters.

    MRP_Flow_Schedule_PVT.PVT_Flow_Sched_Rec_To_PUB(l_flow_schedule_rec,x_flow_schedule_rec);


    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_flow_schedule_rec           => l_flow_schedule_rec
        ,   x_flow_schedule_val_rec       => l_x_flow_schedule_val_rec
        );

	MRP_Flow_Schedule_PVT.PVT_Flow_Sched_Val_Rec_To_PUB(l_x_flow_schedule_val_rec,x_flow_schedule_val_rec);

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Flow_Schedule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Flow_Schedule;

--  Start of Comments
--  API name    Lock_Flow_Schedule
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Flow_Schedule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  Flow_Schedule_Rec_Type :=
                                        G_MISS_FLOW_SCHEDULE_REC
,   p_flow_schedule_val_rec         IN  Flow_Schedule_Val_Rec_Type :=
                                        G_MISS_FLOW_SCHEDULE_VAL_REC
,   x_flow_schedule_rec             OUT NOCOPY Flow_Schedule_Rec_Type
,   x_flow_schedule_val_rec         OUT NOCOPY Flow_Schedule_Val_Rec_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Flow_Schedule';
l_return_status               VARCHAR2(1);
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_flow_schedule_val_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type;
l_x_flow_schedule_val_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    MRP_Flow_Schedule_PVT.PUB_Flow_Sched_Rec_To_PVT(p_flow_schedule_rec,l_p_flow_schedule_rec);
    MRP_Flow_Schedule_PVT.PUB_Flow_Sched_Val_Rec_To_PVT(p_flow_schedule_val_rec,l_p_flow_schedule_val_rec);

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_flow_schedule_rec           => l_p_flow_schedule_rec
    ,   p_flow_schedule_val_rec       => l_p_flow_schedule_val_rec
    ,   x_flow_schedule_rec           => l_flow_schedule_rec
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call MRP_Flow_Schedule_PVT.Lock_Flow_Schedule

    MRP_Flow_Schedule_PVT.Lock_Flow_Schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_flow_schedule_rec           => l_flow_schedule_rec
    ,   x_flow_schedule_rec           => l_flow_schedule_rec
    );

    --  Load Id OUT parameters.

    MRP_Flow_Schedule_PVT.PVT_Flow_Sched_Rec_To_PUB(l_flow_schedule_rec,x_flow_schedule_rec);

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_flow_schedule_rec           => l_flow_schedule_rec
        ,   x_flow_schedule_val_rec       => l_x_flow_schedule_val_rec
        );

        MRP_Flow_Schedule_PVT.PVT_Flow_Sched_Val_Rec_To_PUB(l_x_flow_schedule_val_rec,x_flow_schedule_val_rec);

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Flow_Schedule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Flow_Schedule;

--  Start of Comments
--  API name    Get_Flow_Schedule
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Flow_Schedule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_wip_entity_id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_wip_entity                    IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_flow_schedule_rec             OUT NOCOPY Flow_Schedule_Rec_Type
,   x_flow_schedule_val_rec         OUT NOCOPY Flow_Schedule_Val_Rec_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Flow_Schedule';
l_wip_entity_id               NUMBER := p_wip_entity_id;
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_x_flow_schedule_val_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Standard check for Val/ID conversion

    IF  p_wip_entity = FND_API.G_MISS_CHAR
    THEN

        l_wip_entity_id := p_wip_entity_id;

    ELSIF p_wip_entity_id <> FND_API.G_MISS_NUM THEN

        l_wip_entity_id := p_wip_entity_id;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','wip_entity');
            FND_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        l_wip_entity_id := MRP_Value_To_Id.wip_entity
        (   p_wip_entity                  => p_wip_entity
        );

        IF l_wip_entity_id = FND_API.G_MISS_NUM THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_BUSINESS_OBJ_VALUE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','wip_entity');
                FND_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call MRP_Flow_Schedule_PVT.Get_Flow_Schedule

    MRP_Flow_Schedule_PVT.Get_Flow_Schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_wip_entity_id               => l_wip_entity_id
    ,   x_flow_schedule_rec           => l_flow_schedule_rec
    );

    --  Load Id OUT parameters.

    MRP_Flow_Schedule_PVT.PVT_Flow_Sched_Rec_To_PUB(l_flow_schedule_rec,x_flow_schedule_rec);

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_flow_schedule_rec           => l_flow_schedule_rec
        ,   x_flow_schedule_val_rec       => l_x_flow_schedule_val_rec
        );

	    MRP_Flow_Schedule_PVT.PVT_Flow_Sched_Val_Rec_To_PUB(l_x_flow_schedule_val_rec,x_flow_schedule_val_rec);

    END IF;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Flow_Schedule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Flow_Schedule;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_val_rec         OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type
)
IS
  l_p_old_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type ;
BEGIN

    --  Convert flow_schedule

    x_flow_schedule_val_rec := MRP_Flow_Schedule_Util.Get_Values(p_flow_schedule_rec,l_p_old_flow_schedule_rec);

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Id_To_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_flow_schedule_val_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type
,   x_flow_schedule_rec             OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert flow_schedule

    l_flow_schedule_rec := MRP_Flow_Schedule_Util.Get_Ids
    (   p_flow_schedule_rec           => p_flow_schedule_rec
    ,   p_flow_schedule_val_rec       => p_flow_schedule_val_rec
    );

    x_flow_schedule_rec            := l_flow_schedule_rec;

    IF l_flow_schedule_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;

--  Start of Comments
--  API name    Line_Schedule
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Line_Schedule
(   p_api_version_number            IN  NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_rule_id                       IN NUMBER
,   p_line_id                       IN NUMBER
,   p_org_id                        IN NUMBER
,   p_sched_start_date              IN DATE
,   p_sched_end_date                IN DATE
,   p_update                        IN NUMBER
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Line_Schedule';
l_return_status               VARCHAR2(1);
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    MRP_Flow_Schedule_Util.Line_Schedule (
                     p_rule_id          ,
                     p_line_id          ,
                     p_org_id           ,
                     p_sched_start_date ,
                     p_sched_end_date   ,
                     p_update           ,
		     2			,
                     x_return_status    ,
                     x_msg_count        ,
                     x_msg_data         );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Schedule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Line_Schedule;

--  Start of Comments
--  API name    get_first_unit_completion_date
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

FUNCTION get_first_unit_completion_date
(   p_api_version_number            IN  NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_org_id                        IN NUMBER
,   p_item_id                       IN NUMBER
,   p_qty                           IN NUMBER
,   p_line_id                       IN NUMBER
,   p_start_date                    IN DATE
) RETURN DATE
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'get_first_unit_completion_date';
l_date			      DATE;
l_qty                         NUMBER := 1;/* Added l_qty for bugfix:7211657 */
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     /* Changed p_qty to l_qty in below call as we need only first unit completion date.Setting for bugfix:7211657 */

    l_date := MRP_LINE_SCHEDULE_ALGORITHM.calculate_completion_time (
                     p_org_id   ,
                     p_item_id  ,
                     --p_qty    ,
                     l_qty,
                     p_line_id  ,
                     p_start_date );

    return l_date;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        return NULL;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        return NULL;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'get_first_unit_completion_date'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        return NULL;

END get_first_unit_completion_date;

--  Start of Comments
--  API name    get_operation_offset_date
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
--  This API is a wrapper to feeder_line_comp_date function that is used to find
--  the time in which the operation in the network routing start.
--  If the p_calculate_option = 0, the API will calculate the operation start time of the last quantity.
--  If the p_calculate_option = 1, the API will calculate the operation start time of the 1st quantity.

FUNCTION get_operation_offset_date
(p_api_version_number           IN NUMBER,
x_return_status                 OUT NOCOPY VARCHAR2,
x_msg_count                     OUT NOCOPY NUMBER,
x_msg_data                      OUT NOCOPY VARCHAR2,
p_org_id                        IN NUMBER,
p_assembly_item_id              IN NUMBER,
p_routing_sequence_id           IN NUMBER,
p_operation_sequence_id         IN NUMBER,
p_assembly_qty                  IN NUMBER,
p_assembly_comp_date            IN DATE,
p_calculate_option              IN NUMBER
) return DATE
IS
l_op_date 			DATE;
l_line_id 			NUMBER;
l_cnt 				NUMBER;
l_api_version_number          	CONSTANT NUMBER := 1.0;
l_api_name                    	CONSTANT VARCHAR2(30):= 'get_operation_offset_date';

BEGIN
  --  Standard call to check for call compatibility

  IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT line_id
  INTO l_line_id
  FROM BOM_OPERATIONAL_ROUTINGS
  WHERE ROUTING_SEQUENCE_ID = p_routing_sequence_id
    AND ASSEMBLY_ITEM_ID = p_assembly_item_id
    AND ORGANIZATION_ID = p_org_id;

  IF (p_calculate_option NOT IN (0,1)) THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_BUSINESS_OBJ_VALUE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','calculate_option');
      FND_MSG_PUB.Add;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT count(*)
  INTO l_cnt
  FROM BOM_OPERATION_SEQUENCES
  WHERE OPERATION_SEQUENCE_ID = p_operation_sequence_id
    AND ROUTING_SEQUENCE_ID = p_routing_sequence_id;
  IF (l_cnt = 0) THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_BUSINESS_OBJ_VALUE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operation_sequence_id');
      FND_MSG_PUB.Add;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_op_date := FLM_CREATE_PRODUCT_SYNCH.feeder_line_comp_date (p_org_id,
                             l_line_id,
                             p_assembly_item_id,
                             p_assembly_comp_date,
                             p_assembly_comp_date,
                             p_operation_sequence_id,
                             p_assembly_qty,
                             p_calculate_option);

  return l_op_date;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        return NULL;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        return NULL;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'get_operation_offset_date'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        return NULL;

END get_operation_offset_date;


--  Start of Comments
--  API name    unlink_order_line
--  Type        Public
--  Procedure
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--  This API removes sales order line reference in the flow
--  schedules. It finds flow schedules that has this order line
--  as demand, then null the demand fields.
--  It is only for sales order.
--
--  End of Comments


procedure unlink_order_line
(
p_api_version_number 		IN NUMBER,
x_return_status		 	OUT NOCOPY VARCHAR2,
x_msg_count 			OUT NOCOPY NUMBER,
x_msg_data 			OUT NOCOPY VARCHAR2,
p_assembly_item_id 		IN NUMBER,
p_line_id IN NUMBER
)
IS
l_api_version_number          	CONSTANT NUMBER := 1.0;
l_api_name                    	CONSTANT VARCHAR2(30):= 'unlink_order_line';

l_item_id NUMBER;

BEGIN
  --  Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    select inventory_item_id
    into l_item_id
    from oe_order_lines_all
    where line_id = p_line_id;
  EXCEPTION WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_OE_LINE_ID');
      FND_MSG_PUB.Add;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END;

  if( p_assembly_item_id is null or l_item_id <> p_assembly_item_id ) then
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('MRP','MRP_ITEM_OE_LINE_ID_NOT_MATCH');
      FND_MSG_PUB.Add;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  update wip_flow_schedules
  set demand_source_header_id = null,
      demand_source_line = null,
      demand_source_type = null,
      demand_source_delivery = null
  where demand_source_line = to_char(p_line_id)
    and primary_item_id = p_assembly_item_id
    and demand_source_type = 2 ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'get_operation_offset_date'
            );
        END IF;

        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END unlink_order_line;

END MRP_Flow_Schedule_PUB;

/
