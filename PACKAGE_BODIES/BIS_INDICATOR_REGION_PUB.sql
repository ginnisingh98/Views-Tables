--------------------------------------------------------
--  DDL for Package Body BIS_INDICATOR_REGION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_INDICATOR_REGION_PUB" AS
/* $Header: BISPREGB.pls 115.26 2003/01/30 09:08:44 sugopal ship $ */

Procedure Create_User_Ind_Selection(
        p_api_version           IN NUMBER,
        p_Indicator_Region_Rec
          IN BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id             NUMBER;
l_user_name           VARCHAR2(100);
l_user_ind_id         NUMBER;
l_error_Tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;
l_rowid               VARCHAR2(18);
e_CreateException     EXCEPTION;
cursor c is
   select rowid from BIS_USER_IND_SELECTIONS
   where IND_SELECTION_ID = l_user_ind_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   BIS_UTILITIES_PUB.Retrieve_User(
      p_user_id              => p_Indicator_Region_Rec.user_id
     ,p_user_name            => p_Indicator_Region_Rec.user_name
     ,x_user_id              => l_user_id
     ,x_user_name            => l_user_name
     ,x_return_status        => x_return_status
     ,x_error_Tbl            => x_error_Tbl
   );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE e_CreateException;
  END IF;

  BIS_INDICATOR_REGION_PVT.Validate_User_Ind_Selection(
        p_api_version               => 1.0,
        p_event                     => 'CREATE',
        p_user_id                   => l_user_id,
        p_Indicator_Region_Rec      => p_Indicator_Region_Rec,
        x_return_status	            => x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE e_CreateException;
  END IF;

  BIS_INDICATOR_REGION_PVT.Create_User_Ind_Selection(
        p_api_version            => 1.0,
        p_Indicator_Region_Rec   => p_Indicator_Region_Rec,
        x_return_status	         => x_return_status ,
        x_error_Tbl              => x_error_Tbl);

EXCEPTION
  WHEN e_CreateException THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
  htp.p('BIS_INDICATOR_REGION_PUB.Create_User_Ind_Selection:'||SQLERRM); htp.para;

END Create_User_Ind_Selection;

Procedure Retrieve_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER Default BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name             IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id               IN NUMBER ,
        p_all_info              IN VARCHAR2 Default FND_API.G_TRUE,
        x_Indicator_Region_Tbl
          OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Indicator_Region_rec  BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type;
e_RetrieveException     EXCEPTION;
l_error_tbl            BIS_UTILITIES_PUB.Error_Tbl_Type;
l_Indicator_Region_Tbl BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   BIS_UTILITIES_PUB.Retrieve_User(
      p_user_id              => p_user_id
     ,p_user_name            => p_user_name
     ,x_user_id              => l_indicator_region_rec.user_id
     ,x_user_name            => l_indicator_region_rec.user_name
     ,x_return_status        => x_return_status
     ,x_error_Tbl            => x_error_Tbl
   );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE e_RetrieveException;
  END IF;

  l_Indicator_Region_rec.plug_id := p_plug_id;

  BIS_INDICATOR_REGION_PVT.Validate_User_Ind_Selection(
        p_api_version               => 1.0,
        p_event                     => 'RETRIEVE',
        p_user_id                   => l_indicator_region_rec.user_id,
        p_Indicator_Region_Rec      => l_Indicator_Region_Rec,
        x_return_status	            => x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE e_RetrieveException;
  END IF;

  BIS_INDICATOR_REGION_PVT.Retrieve_User_Ind_Selections(
        p_api_version               => 1.0,
        p_user_id                   => l_indicator_region_rec.user_id,
        p_user_name                 => l_indicator_region_rec.user_name,
        p_plug_id                   => l_indicator_region_rec.plug_id,
        p_all_info                  => p_all_info,
        x_Indicator_Region_Tbl      => x_Indicator_Region_Tbl,
        x_return_status	            => x_return_status ,
        x_error_Tbl                 => x_error_Tbl);

  -- mdamle 01/15/2001 - Resequence Dimensions
  IF (x_Indicator_Region_Tbl.COUNT > 0) THEN
	  l_Indicator_Region_Tbl := x_Indicator_Region_Tbl;
    FOR l_count IN 1..l_Indicator_Region_Tbl.COUNT LOOP
        BIS_UTILITIES_PVT.reseq_ind_dim_level_values(l_Indicator_Region_Tbl(l_count),
					        'R',
                            x_Indicator_Region_Tbl(l_count),
				            x_Error_tbl);
        END LOOP;
  END IF;

EXCEPTION
  WHEN e_RetrieveException THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
  htp.p('BIS_INDICATOR_REGION_PUB.Retrieve_User_Ind_Selections:'||SQLERRM);
  htp.para;

END Retrieve_User_Ind_Selections;

Procedure Retrieve_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_all_info              IN VARCHAR2 Default FND_API.G_TRUE,
        p_Target_level_rec      IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type,
        x_Indicator_Region_Tbl
          OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_Indicator_Region_rec  BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type;
l_target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
e_RetrieveException     EXCEPTION;
l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
l_target_level_rec_p    BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_Indicator_Region_Tbl  BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Target_level_rec := p_Target_level_rec;

  IF BIS_UTILITIES_PUB.VALUE_MISSING(p_Target_level_rec.Target_Level_ID)
    = FND_API.G_TRUE THEN

  -- mdamle 01/15/2001 - Resequence Dimensions
  IF (l_target_level_rec.org_level_id IS NOT NULL) AND
     (l_target_level_rec.time_level_id IS NOT NULL) THEN
      l_target_level_Rec_p := l_target_level_Rec;
			BIS_UTILITIES_PVT.resequence_dim_levels(l_target_level_rec_p,
					'N',
                    l_target_level_Rec,
				    x_Error_tbl);
  end if;

      l_target_level_Rec_p := l_target_level_Rec;
      BIS_TARGET_LEVEL_PUB.Retrieve_Target_Level
      ( p_api_version         => 1.0
      , p_Target_level_rec    => l_Target_level_rec_p
      , p_all_info            => FND_API.G_FALSE
      , x_Target_level_rec    => l_Target_level_rec
      , x_return_status       => x_return_status
      , x_error_Tbl           => x_error_Tbl
      );

	  -- mdamle 01/15/2001 - Resequence Dimensions
      l_target_level_Rec_p := l_target_level_Rec;
      BIS_UTILITIES_PVT.resequence_dim_levels(l_target_level_rec_p,
					'R',
                    l_target_level_Rec,
				    x_Error_tbl);

      -- meastmon 07/31/2001
      --Comment this line which is causing error
      --htp.p('tar lev aft retrieve: ' ||l_Target_level_rec.Target_Level_ID);

      --dbms_output.put_line('tar lev aft retrieve: '
      --                    ||l_Target_level_rec.Target_Level_ID);
  END IF;

  BIS_INDICATOR_REGION_PVT.Retrieve_User_Ind_Selections
  (  p_api_version              => 1.0
  , p_all_info                  => p_all_info
  , p_Target_level_id           => l_Target_level_rec.Target_Level_ID
  , x_Indicator_Region_Tbl      => x_Indicator_Region_Tbl
  , x_return_status	        => x_return_status
  , x_error_Tbl                 => x_error_Tbl
  );

  -- mdamle 01/15/2001 - Resequence Dimensions
  IF (x_Indicator_Region_Tbl.COUNT > 0) THEN
    l_Indicator_Region_Tbl := x_Indicator_Region_Tbl;
		FOR l_count IN 1..l_Indicator_Region_Tbl.COUNT LOOP
        BIS_UTILITIES_PVT.reseq_ind_dim_level_values(l_Indicator_Region_Tbl(l_count),
					        'R',
                            x_Indicator_Region_Tbl(l_count),
				            x_Error_tbl);
        END LOOP;
  END IF;


EXCEPTION
  WHEN e_RetrieveException THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );

END Retrieve_User_Ind_Selections;


Procedure Update_User_Ind_Selection(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER Default BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name             IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id               IN NUMBER ,
        p_Indicator_Region_Tbl
          IN BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id NUMBER;
l_user_name VARCHAR2(100);
l_error_Tbl   BIS_UTILITIES_PUB.Error_Tbl_Type;

e_UpdateException EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   BIS_UTILITIES_PUB.Retrieve_User(
      p_user_id              => p_user_id
     ,p_user_name            => p_user_name
     ,x_user_id              => l_user_id
     ,x_user_name            => l_user_name
     ,x_return_status        => x_return_status
     ,x_error_Tbl            => x_error_Tbl
   );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE e_UpdateException;
  END IF;

  FOR i in 1..p_Indicator_Region_Tbl.count LOOP

    BIS_INDICATOR_REGION_PVT.Validate_User_Ind_Selection(
        p_api_version               => 1.0,
        p_event                     => 'UPDATE',
        p_user_id                   => l_user_id,
        p_Indicator_Region_Rec      => p_Indicator_Region_Tbl(i),
        x_return_status	            => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_UpdateException;
      END IF;

    BIS_INDICATOR_REGION_PVT.Update_User_Ind_Selection(
        p_api_version               => 1.0,
        p_user_id                   => l_user_id,
        p_user_name                 => l_user_name,
        p_plug_id                   => p_plug_id,
        p_Indicator_Region_Rec      => p_Indicator_Region_Tbl(i),
        x_return_status	            => x_return_status ,
        x_error_Tbl                 => x_error_Tbl);

  END LOOP;

EXCEPTION
  WHEN e_UpdateException THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
  htp.p('BIS_INDICATOR_REGION_PUB.Update_User_Ind_Selection:'||SQLERRM); htp.para;

END Update_User_Ind_Selection;


Procedure Delete_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER Default BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name             IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id               IN NUMBER,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Indicator_Region_rec  BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type;
l_user_id               NUMBER;
l_user_name             VARCHAR2(100);
l_error_Tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
e_DeleteException       EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   BIS_UTILITIES_PUB.Retrieve_User(
      p_user_id              => p_user_id
     ,p_user_name            => p_user_name
     ,x_user_id              => l_user_id
     ,x_user_name            => l_user_name
     ,x_return_status        => x_return_status
     ,x_error_Tbl            => x_error_Tbl
   );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE e_DeleteException;
  END IF;

  l_Indicator_Region_rec.user_id := l_user_id;
  l_Indicator_Region_rec.user_name := l_user_name;
  l_Indicator_Region_rec.plug_id := p_plug_id;

  BIS_INDICATOR_REGION_PVT.Validate_User_Ind_Selection(
        p_api_version               => 1.0,
        p_event                     => 'DELETE',
        p_user_id                   => l_Indicator_Region_Rec.user_id,
        p_Indicator_Region_Rec      => l_Indicator_Region_Rec,
        x_return_status	            => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_DeleteException;
      END IF;

  BIS_INDICATOR_REGION_PVT.Delete_User_Ind_Selections(
        p_api_version               => 1.0,
        p_user_id                   => l_indicator_region_rec.user_id,
        p_user_name                 => l_indicator_region_rec.user_name,
        p_plug_id                   => l_indicator_region_rec.plug_id,
        x_return_status	            => x_return_status ,
        x_error_Tbl                 => x_error_Tbl);

EXCEPTION
  WHEN e_DeleteException THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
  htp.p('BIS_INDICATOR_REGION_PUB.Delete_User_Ind_Selection:'||SQLERRM); htp.para;

END Delete_User_Ind_Selections;


END BIS_INDICATOR_REGION_PUB;

/
