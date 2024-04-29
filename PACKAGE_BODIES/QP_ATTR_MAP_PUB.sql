--------------------------------------------------------
--  DDL for Package Body QP_ATTR_MAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ATTR_MAP_PUB" AS
/* $Header: QPXPMAPB.pls 120.4 2005/08/18 15:54:18 sfiresto ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Attr_Map_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_PTE_rec                       IN  Pte_Rec_Type
,   p_RQT_tbl                       IN  Rqt_Tbl_Type
,   p_SSC_tbl                       IN  Ssc_Tbl_Type
,   p_PSG_tbl                       IN  Psg_Tbl_Type
,   p_SOU_tbl                       IN  Sou_Tbl_Type
,   p_FNA_tbl                       IN  Fna_Tbl_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
,   x_FNA_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Fna_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  Pte_Rec_Type
,   p_PTE_val_rec                   IN  Pte_Val_Rec_Type
,   p_RQT_tbl                       IN  Rqt_Tbl_Type
,   p_RQT_val_tbl                   IN  Rqt_Val_Tbl_Type
,   p_SSC_tbl                       IN  Ssc_Tbl_Type
,   p_SSC_val_tbl                   IN  Ssc_Val_Tbl_Type
,   p_PSG_tbl                       IN  Psg_Tbl_Type
,   p_PSG_val_tbl                   IN  Psg_Val_Tbl_Type
,   p_SOU_tbl                       IN  Sou_Tbl_Type
,   p_SOU_val_tbl                   IN  Sou_Val_Tbl_Type
,   p_FNA_tbl                       IN  Fna_Tbl_Type
,   p_FNA_val_tbl                   IN  Fna_Val_Tbl_Type
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ Fna_Tbl_Type
);

--  Start of Comments
--  API name    Process_Attr_Mapping
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

PROCEDURE Process_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  Pte_Rec_Type :=
                                        G_MISS_PTE_REC
,   p_PTE_val_rec                   IN  Pte_Val_Rec_Type :=
                                        G_MISS_PTE_VAL_REC
,   p_RQT_tbl                       IN  Rqt_Tbl_Type :=
                                        G_MISS_RQT_TBL
,   p_RQT_val_tbl                   IN  Rqt_Val_Tbl_Type :=
                                        G_MISS_RQT_VAL_TBL
,   p_SSC_tbl                       IN  Ssc_Tbl_Type :=
                                        G_MISS_SSC_TBL
,   p_SSC_val_tbl                   IN  Ssc_Val_Tbl_Type :=
                                        G_MISS_SSC_VAL_TBL
,   p_PSG_tbl                       IN  Psg_Tbl_Type :=
                                        G_MISS_PSG_TBL
,   p_PSG_val_tbl                   IN  Psg_Val_Tbl_Type :=
                                        G_MISS_PSG_VAL_TBL
,   p_SOU_tbl                       IN  Sou_Tbl_Type :=
                                        G_MISS_SOU_TBL
,   p_SOU_val_tbl                   IN  Sou_Val_Tbl_Type :=
                                        G_MISS_SOU_VAL_TBL
,   p_FNA_tbl                       IN  Fna_Tbl_Type :=
                                        G_MISS_FNA_TBL
,   p_FNA_val_tbl                   IN  Fna_Val_Tbl_Type :=
                                        G_MISS_FNA_VAL_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ Fna_Tbl_Type
,   x_FNA_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Fna_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Attr_Mapping';
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_PTE_rec                     Pte_Rec_Type;
l_p_PTE_rec                     Pte_Rec_Type;
l_RQT_tbl                     Rqt_Tbl_Type;
l_p_RQT_tbl                     Rqt_Tbl_Type;
l_SSC_tbl                     Ssc_Tbl_Type;
l_p_SSC_tbl                     Ssc_Tbl_Type;
l_PSG_tbl                     Psg_Tbl_Type;
l_p_PSG_tbl                     Psg_Tbl_Type;
l_SOU_tbl                     Sou_Tbl_Type;
l_p_SOU_tbl                     Sou_Tbl_Type;
l_FNA_tbl                     Fna_Tbl_Type;
l_p_FNA_tbl                     Fna_Tbl_Type;
l_enabled_fnas_ret_sts        VARCHAR2(1);
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

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_PTE_rec                     => p_PTE_rec
    ,   p_PTE_val_rec                 => p_PTE_val_rec
    ,   p_RQT_tbl                     => p_RQT_tbl
    ,   p_RQT_val_tbl                 => p_RQT_val_tbl
    ,   p_SSC_tbl                     => p_SSC_tbl
    ,   p_SSC_val_tbl                 => p_SSC_val_tbl
    ,   p_PSG_tbl                     => p_PSG_tbl
    ,   p_PSG_val_tbl                 => p_PSG_val_tbl
    ,   p_SOU_tbl                     => p_SOU_tbl
    ,   p_SOU_val_tbl                 => p_SOU_val_tbl
    ,   p_FNA_tbl                     => p_FNA_tbl
    ,   p_FNA_val_tbl                 => p_FNA_val_tbl
    ,   x_PTE_rec                     => l_PTE_rec
    ,   x_RQT_tbl                     => l_RQT_tbl
    ,   x_SSC_tbl                     => l_SSC_tbl
    ,   x_PSG_tbl                     => l_PSG_tbl
    ,   x_SOU_tbl                     => l_SOU_tbl
    ,   x_FNA_tbl                     => l_FNA_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Attr_Map_PVT.Process_Attr_Mapping
    l_p_PTE_rec := l_PTE_rec;
    l_p_RQT_tbl := l_RQT_tbl;
    l_p_SSC_tbl := l_SSC_tbl;
    l_p_PSG_tbl := l_PSG_tbl;
    l_p_SOU_tbl := l_SOU_tbl;
    l_p_FNA_tbl := l_FNA_tbl;

    QP_Attr_Map_PVT.Process_Attr_Mapping
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PTE_rec                     => l_p_PTE_rec
    ,   p_RQT_tbl                     => l_p_RQT_tbl
    ,   p_SSC_tbl                     => l_p_SSC_tbl
    ,   p_PSG_tbl                     => l_p_PSG_tbl
    ,   p_SOU_tbl                     => l_p_SOU_tbl
    ,   p_FNA_tbl                     => l_p_FNA_tbl
    ,   x_PTE_rec                     => l_PTE_rec
    ,   x_RQT_tbl                     => l_RQT_tbl
    ,   x_SSC_tbl                     => l_SSC_tbl
    ,   x_PSG_tbl                     => l_PSG_tbl
    ,   x_SOU_tbl                     => l_SOU_tbl
    ,   x_FNA_tbl                     => l_FNA_tbl
    );

    --  Load Id OUT parameters.

    x_PTE_rec                      := l_PTE_rec;
    x_RQT_tbl                      := l_RQT_tbl;
    x_SSC_tbl                      := l_SSC_tbl;
    x_PSG_tbl                      := l_PSG_tbl;
    x_SOU_tbl                      := l_SOU_tbl;
    x_FNA_tbl                      := l_FNA_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_PTE_rec                     => l_PTE_rec
        ,   p_RQT_tbl                     => l_RQT_tbl
        ,   p_SSC_tbl                     => l_SSC_tbl
        ,   p_PSG_tbl                     => l_PSG_tbl
        ,   p_SOU_tbl                     => l_SOU_tbl
        ,   p_FNA_tbl                     => l_FNA_tbl
        ,   x_PTE_val_rec                 => x_PTE_val_rec
        ,   x_RQT_val_tbl                 => x_RQT_val_tbl
        ,   x_SSC_val_tbl                 => x_SSC_val_tbl
        ,   x_PSG_val_tbl                 => x_PSG_val_tbl
        ,   x_SOU_val_tbl                 => x_SOU_val_tbl
        ,   x_FNA_val_tbl                 => x_FNA_val_tbl
        );

    END IF;

    -- If Process_Attr_mapping is successful, Check for Enabled Fnas
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      QP_Attr_Map_PVT.Check_Enabled_Fnas
      ( x_msg_data      => x_msg_data
      , x_msg_count     => x_msg_count
      , x_return_status => l_enabled_fnas_ret_sts
      );
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Attr_Mapping'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Attr_Mapping;

--  Start of Comments
--  API name    Process_Attr_Mapping (Overloaded)
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

PROCEDURE Process_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  Pte_Rec_Type :=
                                        G_MISS_PTE_REC
,   p_PTE_val_rec                   IN  Pte_Val_Rec_Type :=
                                        G_MISS_PTE_VAL_REC
,   p_RQT_tbl                       IN  Rqt_Tbl_Type :=
                                        G_MISS_RQT_TBL
,   p_RQT_val_tbl                   IN  Rqt_Val_Tbl_Type :=
                                        G_MISS_RQT_VAL_TBL
,   p_SSC_tbl                       IN  Ssc_Tbl_Type :=
                                        G_MISS_SSC_TBL
,   p_SSC_val_tbl                   IN  Ssc_Val_Tbl_Type :=
                                        G_MISS_SSC_VAL_TBL
,   p_PSG_tbl                       IN  Psg_Tbl_Type :=
                                        G_MISS_PSG_TBL
,   p_PSG_val_tbl                   IN  Psg_Val_Tbl_Type :=
                                        G_MISS_PSG_VAL_TBL
,   p_SOU_tbl                       IN  Sou_Tbl_Type :=
                                        G_MISS_SOU_TBL
,   p_SOU_val_tbl                   IN  Sou_Val_Tbl_Type :=
                                        G_MISS_SOU_VAL_TBL
,   p_FNA_tbl                       IN  Fna_Tbl_Type :=
                                        G_MISS_FNA_TBL
,   p_FNA_val_tbl                   IN  Fna_Val_Tbl_Type :=
                                        G_MISS_FNA_VAL_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
)
IS
l_FNA_tbl                     Fna_Tbl_Type;
l_FNA_val_tbl                 Fna_Val_Tbl_Type;
BEGIN
  Process_Attr_Mapping( p_api_version_number  => p_api_version_number
                      , p_init_msg_list       => p_init_msg_list
                      , p_return_values       => p_return_values
                      , p_commit              => p_commit
                      , x_return_status       => x_return_status
                      , x_msg_count           => x_msg_count
                      , x_msg_data            => x_msg_data
                      , p_PTE_rec             => p_PTE_rec
                      , p_PTE_val_rec         => p_PTE_val_rec
                      , p_RQT_tbl             => p_RQT_tbl
                      , p_RQT_val_tbl         => p_RQT_val_tbl
                      , p_SSC_tbl             => p_SSC_tbl
                      , p_SSC_val_tbl         => p_SSC_val_tbl
                      , p_PSG_tbl             => p_PSG_tbl
                      , p_PSG_val_tbl         => p_PSG_val_tbl
                      , p_SOU_tbl             => p_SOU_tbl
                      , p_SOU_val_tbl         => p_SOU_val_tbl
                      , p_FNA_tbl             => p_FNA_tbl
                      , p_FNA_val_tbl         => p_FNA_val_tbl
                      , x_PTE_rec             => x_PTE_rec
                      , x_PTE_val_rec         => x_PTE_val_rec
                      , x_RQT_tbl             => x_RQT_tbl
                      , x_RQT_val_tbl         => x_RQT_val_tbl
                      , x_SSC_tbl             => x_SSC_tbl
                      , x_SSC_val_tbl         => x_SSC_val_tbl
                      , x_PSG_tbl             => x_PSG_tbl
                      , x_PSG_val_tbl         => x_PSG_val_tbl
                      , x_SOU_tbl             => x_SOU_tbl
                      , x_SOU_val_tbl         => x_SOU_val_tbl
                      , x_FNA_tbl             => l_FNA_tbl
                      , x_FNA_val_tbl         => l_FNA_val_tbl
                      );


END Process_Attr_Mapping;

--  Start of Comments
--  API name    Lock_Attr_Mapping
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

PROCEDURE Lock_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  Pte_Rec_Type :=
                                        G_MISS_PTE_REC
,   p_PTE_val_rec                   IN  Pte_Val_Rec_Type :=
                                        G_MISS_PTE_VAL_REC
,   p_RQT_tbl                       IN  Rqt_Tbl_Type :=
                                        G_MISS_RQT_TBL
,   p_RQT_val_tbl                   IN  Rqt_Val_Tbl_Type :=
                                        G_MISS_RQT_VAL_TBL
,   p_SSC_tbl                       IN  Ssc_Tbl_Type :=
                                        G_MISS_SSC_TBL
,   p_SSC_val_tbl                   IN  Ssc_Val_Tbl_Type :=
                                        G_MISS_SSC_VAL_TBL
,   p_PSG_tbl                       IN  Psg_Tbl_Type :=
                                        G_MISS_PSG_TBL
,   p_PSG_val_tbl                   IN  Psg_Val_Tbl_Type :=
                                        G_MISS_PSG_VAL_TBL
,   p_SOU_tbl                       IN  Sou_Tbl_Type :=
                                        G_MISS_SOU_TBL
,   p_SOU_val_tbl                   IN  Sou_Val_Tbl_Type :=
                                        G_MISS_SOU_VAL_TBL
,   p_FNA_tbl                       IN  Fna_Tbl_Type :=
                                        G_MISS_FNA_TBL
,   p_FNA_val_tbl                   IN  Fna_Val_Tbl_Type :=
                                        G_MISS_FNA_VAL_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ Fna_Tbl_Type
,   x_FNA_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Fna_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Attr_Mapping';
l_return_status               VARCHAR2(1);
l_PTE_rec                     Pte_Rec_Type;
l_p_PTE_rec                     Pte_Rec_Type;
l_RQT_tbl                     Rqt_Tbl_Type;
l_p_RQT_tbl                     Rqt_Tbl_Type;
l_SSC_tbl                     Ssc_Tbl_Type;
l_p_SSC_tbl                     Ssc_Tbl_Type;
l_PSG_tbl                     Psg_Tbl_Type;
l_p_PSG_tbl                     Psg_Tbl_Type;
l_SOU_tbl                     Sou_Tbl_Type;
l_p_SOU_tbl                     Sou_Tbl_Type;
l_FNA_tbl                     Fna_Tbl_Type;
l_p_FNA_tbl                     Fna_Tbl_Type;
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

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_PTE_rec                     => p_PTE_rec
    ,   p_PTE_val_rec                 => p_PTE_val_rec
    ,   p_RQT_tbl                     => p_RQT_tbl
    ,   p_RQT_val_tbl                 => p_RQT_val_tbl
    ,   p_SSC_tbl                     => p_SSC_tbl
    ,   p_SSC_val_tbl                 => p_SSC_val_tbl
    ,   p_PSG_tbl                     => p_PSG_tbl
    ,   p_PSG_val_tbl                 => p_PSG_val_tbl
    ,   p_SOU_tbl                     => p_SOU_tbl
    ,   p_SOU_val_tbl                 => p_SOU_val_tbl
    ,   p_FNA_tbl                     => p_FNA_tbl
    ,   p_FNA_val_tbl                 => p_FNA_val_tbl
    ,   x_PTE_rec                     => l_PTE_rec
    ,   x_RQT_tbl                     => l_RQT_tbl
    ,   x_SSC_tbl                     => l_SSC_tbl
    ,   x_PSG_tbl                     => l_PSG_tbl
    ,   x_SOU_tbl                     => l_SOU_tbl
    ,   x_FNA_tbl                     => l_FNA_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Attr_Map_PVT.Lock_Attr_Mapping
    l_p_PTE_rec := l_PTE_rec;
    l_p_RQT_tbl := l_RQT_tbl;
    l_p_SSC_tbl := l_SSC_tbl;
    l_p_PSG_tbl := l_PSG_tbl;
    l_p_SOU_tbl := l_SOU_tbl;
    l_p_FNA_tbl := l_FNA_tbl;

    QP_Attr_Map_PVT.Lock_Attr_Mapping
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_PTE_rec                     => l_p_PTE_rec
    ,   p_RQT_tbl                     => l_p_RQT_tbl
    ,   p_SSC_tbl                     => l_p_SSC_tbl
    ,   p_PSG_tbl                     => l_p_PSG_tbl
    ,   p_SOU_tbl                     => l_p_SOU_tbl
    ,   p_FNA_tbl                     => l_p_FNA_tbl
    ,   x_PTE_rec                     => l_PTE_rec
    ,   x_RQT_tbl                     => l_RQT_tbl
    ,   x_SSC_tbl                     => l_SSC_tbl
    ,   x_PSG_tbl                     => l_PSG_tbl
    ,   x_SOU_tbl                     => l_SOU_tbl
    ,   x_FNA_tbl                     => l_FNA_tbl
    );

    --  Load Id OUT parameters.

    x_PTE_rec                      := l_PTE_rec;
    x_RQT_tbl                      := l_RQT_tbl;
    x_SSC_tbl                      := l_SSC_tbl;
    x_PSG_tbl                      := l_PSG_tbl;
    x_SOU_tbl                      := l_SOU_tbl;
    x_FNA_tbl                      := l_FNA_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_PTE_rec                     => l_PTE_rec
        ,   p_RQT_tbl                     => l_RQT_tbl
        ,   p_SSC_tbl                     => l_SSC_tbl
        ,   p_PSG_tbl                     => l_PSG_tbl
        ,   p_SOU_tbl                     => l_SOU_tbl
        ,   p_FNA_tbl                     => l_FNA_tbl
        ,   x_PTE_val_rec                 => x_PTE_val_rec
        ,   x_RQT_val_tbl                 => x_RQT_val_tbl
        ,   x_SSC_val_tbl                 => x_SSC_val_tbl
        ,   x_PSG_val_tbl                 => x_PSG_val_tbl
        ,   x_SOU_val_tbl                 => x_SOU_val_tbl
        ,   x_FNA_val_tbl                 => x_FNA_val_tbl
        );

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Attr_Mapping'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Attr_Mapping;

--  Start of Comments
--  API name    Lock_Attr_Mapping (Overloaded)
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

PROCEDURE Lock_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  Pte_Rec_Type :=
                                        G_MISS_PTE_REC
,   p_PTE_val_rec                   IN  Pte_Val_Rec_Type :=
                                        G_MISS_PTE_VAL_REC
,   p_RQT_tbl                       IN  Rqt_Tbl_Type :=
                                        G_MISS_RQT_TBL
,   p_RQT_val_tbl                   IN  Rqt_Val_Tbl_Type :=
                                        G_MISS_RQT_VAL_TBL
,   p_SSC_tbl                       IN  Ssc_Tbl_Type :=
                                        G_MISS_SSC_TBL
,   p_SSC_val_tbl                   IN  Ssc_Val_Tbl_Type :=
                                        G_MISS_SSC_VAL_TBL
,   p_PSG_tbl                       IN  Psg_Tbl_Type :=
                                        G_MISS_PSG_TBL
,   p_PSG_val_tbl                   IN  Psg_Val_Tbl_Type :=
                                        G_MISS_PSG_VAL_TBL
,   p_SOU_tbl                       IN  Sou_Tbl_Type :=
                                        G_MISS_SOU_TBL
,   p_SOU_val_tbl                   IN  Sou_Val_Tbl_Type :=
                                        G_MISS_SOU_VAL_TBL
,   p_FNA_tbl                       IN  Fna_Tbl_Type :=
                                        G_MISS_FNA_TBL
,   p_FNA_val_tbl                   IN  Fna_Val_Tbl_Type :=
                                        G_MISS_FNA_VAL_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
)
IS
l_FNA_tbl                     Fna_Tbl_Type;
l_FNA_val_tbl                 Fna_Val_Tbl_Type;
BEGIN
     Lock_Attr_Mapping( p_api_version_number  => p_api_version_number
                      , p_init_msg_list       => p_init_msg_list
                      , p_return_values       => p_return_values
                      , x_return_status       => x_return_status
                      , x_msg_count           => x_msg_count
                      , x_msg_data            => x_msg_data
                      , p_PTE_rec             => p_PTE_rec
                      , p_PTE_val_rec         => p_PTE_val_rec
                      , p_RQT_tbl             => p_RQT_tbl
                      , p_RQT_val_tbl         => p_RQT_val_tbl
                      , p_SSC_tbl             => p_SSC_tbl
                      , p_SSC_val_tbl         => p_SSC_val_tbl
                      , p_PSG_tbl             => p_PSG_tbl
                      , p_PSG_val_tbl         => p_PSG_val_tbl
                      , p_SOU_tbl             => p_SOU_tbl
                      , p_SOU_val_tbl         => p_SOU_val_tbl
                      , p_FNA_tbl             => p_FNA_tbl
                      , p_FNA_val_tbl         => p_FNA_val_tbl
                      , x_PTE_rec             => x_PTE_rec
                      , x_PTE_val_rec         => x_PTE_val_rec
                      , x_RQT_tbl             => x_RQT_tbl
                      , x_RQT_val_tbl         => x_RQT_val_tbl
                      , x_SSC_tbl             => x_SSC_tbl
                      , x_SSC_val_tbl         => x_SSC_val_tbl
                      , x_PSG_tbl             => x_PSG_tbl
                      , x_PSG_val_tbl         => x_PSG_val_tbl
                      , x_SOU_tbl             => x_SOU_tbl
                      , x_SOU_val_tbl         => x_SOU_val_tbl
                      , x_FNA_tbl             => l_FNA_tbl
                      , x_FNA_val_tbl         => l_FNA_val_tbl
                      );
END Lock_Attr_Mapping;

--  Start of Comments
--  API name    Get_Attr_Mapping
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

PROCEDURE Get_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_lookup_code                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_lookup                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ Fna_Tbl_Type
,   x_FNA_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Fna_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Attr_Mapping';
l_lookup_code                 VARCHAR2(30) := p_lookup_code;
l_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type;
l_RQT_tbl                     QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_SSC_tbl                     QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_PSG_tbl                     QP_Attr_Map_PUB.Psg_Tbl_Type;
l_SOU_tbl                     QP_Attr_Map_PUB.Sou_Tbl_Type;
l_FNA_tbl                     QP_Attr_Map_PUB.Fna_Tbl_Type;
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

    IF  p_lookup = FND_API.G_MISS_CHAR
    THEN

        l_lookup_code := p_lookup_code;

    ELSIF p_lookup_code <> FND_API.G_MISS_CHAR THEN

        l_lookup_code := p_lookup_code;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lookup');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        l_lookup_code := QP_Value_To_Id.lookup
        (   p_lookup                      => p_lookup
        );

        IF l_lookup_code = FND_API.G_MISS_CHAR THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lookup');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call QP_Attr_Map_PVT.Get_Attr_Mapping

    QP_Attr_Map_PVT.Get_Attr_Mapping
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_lookup_code                 => l_lookup_code
    ,   x_PTE_rec                     => l_PTE_rec
    ,   x_RQT_tbl                     => l_RQT_tbl
    ,   x_SSC_tbl                     => l_SSC_tbl
    ,   x_PSG_tbl                     => l_PSG_tbl
    ,   x_SOU_tbl                     => l_SOU_tbl
    ,   x_FNA_tbl                     => l_FNA_tbl
    );

    --  Load Id OUT parameters.

    x_PTE_rec                      := l_PTE_rec;
    x_RQT_tbl                      := l_RQT_tbl;
    x_SSC_tbl                      := l_SSC_tbl;
    x_PSG_tbl                      := l_PSG_tbl;
    x_SOU_tbl                      := l_SOU_tbl;
    x_FNA_tbl                      := l_FNA_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_PTE_rec                     => l_PTE_rec
        ,   p_RQT_tbl                     => l_RQT_tbl
        ,   p_SSC_tbl                     => l_SSC_tbl
        ,   p_PSG_tbl                     => l_PSG_tbl
        ,   p_SOU_tbl                     => l_SOU_tbl
        ,   p_FNA_tbl                     => l_FNA_tbl
        ,   x_PTE_val_rec                 => x_PTE_val_rec
        ,   x_RQT_val_tbl                 => x_RQT_val_tbl
        ,   x_SSC_val_tbl                 => x_SSC_val_tbl
        ,   x_PSG_val_tbl                 => x_PSG_val_tbl
        ,   x_SOU_val_tbl                 => x_SOU_val_tbl
        ,   x_FNA_val_tbl                 => x_FNA_val_tbl
        );

    END IF;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Attr_Mapping'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Attr_Mapping;

--  Start of Comments
--  API name    Get_Attr_Mapping (Overloaded)
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

PROCEDURE Get_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_lookup_code                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_lookup                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
)
IS
l_FNA_tbl                     Fna_Tbl_Type;
l_FNA_val_tbl                 Fna_Val_Tbl_Type;
BEGIN
      Get_Attr_Mapping( p_api_version_number  => p_api_version_number
                      , p_init_msg_list       => p_init_msg_list
                      , p_return_values       => p_return_values
                      , x_return_status       => x_return_status
                      , x_msg_count           => x_msg_count
                      , x_msg_data            => x_msg_data
                      , p_lookup_code         => p_lookup_code
                      , p_lookup              => p_lookup
                      , x_PTE_rec             => x_PTE_rec
                      , x_PTE_val_rec         => x_PTE_val_rec
                      , x_RQT_tbl             => x_RQT_tbl
                      , x_RQT_val_tbl         => x_RQT_val_tbl
                      , x_SSC_tbl             => x_SSC_tbl
                      , x_SSC_val_tbl         => x_SSC_val_tbl
                      , x_PSG_tbl             => x_PSG_tbl
                      , x_PSG_val_tbl         => x_PSG_val_tbl
                      , x_SOU_tbl             => x_SOU_tbl
                      , x_SOU_val_tbl         => x_SOU_val_tbl
                      , x_FNA_tbl             => l_FNA_tbl
                      , x_FNA_val_tbl         => l_FNA_val_tbl
                      );
END Get_Attr_Mapping;


--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_PTE_rec                       IN  Pte_Rec_Type
,   p_RQT_tbl                       IN  Rqt_Tbl_Type
,   p_SSC_tbl                       IN  Ssc_Tbl_Type
,   p_PSG_tbl                       IN  Psg_Tbl_Type
,   p_SOU_tbl                       IN  Sou_Tbl_Type
,   p_FNA_tbl                       IN  Fna_Tbl_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
,   x_FNA_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Fna_Val_Tbl_Type
)
IS
BEGIN

    --  Convert PTE

    x_PTE_val_rec := QP_Pte_Util.Get_Values(p_PTE_rec);

    --  Convert RQT

    FOR I IN 1..p_RQT_tbl.COUNT LOOP
        x_RQT_val_tbl(I) :=
            QP_Rqt_Util.Get_Values(p_RQT_tbl(I));
    END LOOP;

    --  Convert SSC

    FOR I IN 1..p_SSC_tbl.COUNT LOOP
        x_SSC_val_tbl(I) :=
            QP_Ssc_Util.Get_Values(p_SSC_tbl(I));
    END LOOP;

    --  Convert PSG

    FOR I IN 1..p_PSG_tbl.COUNT LOOP
        x_PSG_val_tbl(I) :=
            QP_Psg_Util.Get_Values(p_PSG_tbl(I));
    END LOOP;

    --  Convert SOU

    FOR I IN 1..p_SOU_tbl.COUNT LOOP
        x_SOU_val_tbl(I) :=
            QP_Sou_Util.Get_Values(p_SOU_tbl(I));
    END LOOP;

    --  Convert FNA

    FOR I IN 1..p_FNA_tbl.COUNT LOOP
        x_FNA_val_tbl(I) :=
            QP_Fna_Util.Get_Values(p_FNA_tbl(I));
    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Id_To_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  Pte_Rec_Type
,   p_PTE_val_rec                   IN  Pte_Val_Rec_Type
,   p_RQT_tbl                       IN  Rqt_Tbl_Type
,   p_RQT_val_tbl                   IN  Rqt_Val_Tbl_Type
,   p_SSC_tbl                       IN  Ssc_Tbl_Type
,   p_SSC_val_tbl                   IN  Ssc_Val_Tbl_Type
,   p_PSG_tbl                       IN  Psg_Tbl_Type
,   p_PSG_val_tbl                   IN  Psg_Val_Tbl_Type
,   p_SOU_tbl                       IN  Sou_Tbl_Type
,   p_SOU_val_tbl                   IN  Sou_Val_Tbl_Type
,   p_FNA_tbl                       IN  Fna_Tbl_Type
,   p_FNA_val_tbl                   IN  Fna_Val_Tbl_Type
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ Fna_Tbl_Type
)
IS
l_PTE_rec                     Pte_Rec_Type;
l_RQT_rec                     Rqt_Rec_Type;
l_SSC_rec                     Ssc_Rec_Type;
l_PSG_rec                     Psg_Rec_Type;
l_SOU_rec                     Sou_Rec_Type;
l_FNA_rec                     Fna_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert PTE

    l_PTE_rec := QP_Pte_Util.Get_Ids
    (   p_PTE_rec                     => p_PTE_rec
    ,   p_PTE_val_rec                 => p_PTE_val_rec
    );

    x_PTE_rec                      := l_PTE_rec;

    IF l_PTE_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert RQT

    x_RQT_tbl := p_RQT_tbl;

    l_index := p_RQT_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_RQT_rec := QP_Rqt_Util.Get_Ids
        (   p_RQT_rec                     => p_RQT_tbl(l_index)
        ,   p_RQT_val_rec                 => p_RQT_val_tbl(l_index)
        );

        x_RQT_tbl(l_index)             := l_RQT_rec;

        IF l_RQT_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_RQT_val_tbl.NEXT(l_index);

    END LOOP;

    --  Convert SSC

    x_SSC_tbl := p_SSC_tbl;

    l_index := p_SSC_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_SSC_rec := QP_Ssc_Util.Get_Ids
        (   p_SSC_rec                     => p_SSC_tbl(l_index)
        ,   p_SSC_val_rec                 => p_SSC_val_tbl(l_index)
        );

        x_SSC_tbl(l_index)             := l_SSC_rec;

        IF l_SSC_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_SSC_val_tbl.NEXT(l_index);

    END LOOP;

    --  Convert PSG

    x_PSG_tbl := p_PSG_tbl;

    l_index := p_PSG_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_PSG_rec := QP_Psg_Util.Get_Ids
        (   p_PSG_rec                     => p_PSG_tbl(l_index)
        ,   p_PSG_val_rec                 => p_PSG_val_tbl(l_index)
        );

        x_PSG_tbl(l_index)             := l_PSG_rec;

        IF l_PSG_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_PSG_val_tbl.NEXT(l_index);

    END LOOP;

    --  Convert SOU

    x_SOU_tbl := p_SOU_tbl;

    l_index := p_SOU_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_SOU_rec := QP_Sou_Util.Get_Ids
        (   p_SOU_rec                     => p_SOU_tbl(l_index)
        ,   p_SOU_val_rec                 => p_SOU_val_tbl(l_index)
        );

        x_SOU_tbl(l_index)             := l_SOU_rec;

        IF l_SOU_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_SOU_val_tbl.NEXT(l_index);

    END LOOP;

    --  Convert FNA

    x_FNA_tbl := p_FNA_tbl;

    l_index := p_FNA_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_FNA_rec := QP_Fna_Util.Get_Ids
        (   p_FNA_rec                     => p_FNA_tbl(l_index)
        ,   p_FNA_val_rec                 => p_FNA_val_tbl(l_index)
        );

        x_FNA_tbl(l_index)             := l_FNA_rec;

        IF l_FNA_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_FNA_val_tbl.NEXT(l_index);

    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;

END QP_Attr_Map_PUB;

/
