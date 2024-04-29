--------------------------------------------------------
--  DDL for Package Body BIS_BUCKET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BUCKET_PUB" AS
/* $Header: BISPBKTB.pls 115.4 2004/01/24 08:37:51 jxyu noship $ */


--This API should call BIS_BUCKET_PVT.CREATE_BIS_BUCKET
PROCEDURE CREATE_BIS_BUCKET (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  BIS_BUCKET_PVT.CREATE_BIS_BUCKET(
    p_bis_bucket_rec => p_bis_bucket_rec
   ,x_return_status  => x_return_status
   ,x_error_tbl      => x_error_tbl
  );

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message(
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.CREATE_BIS_BUCKET'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );

END CREATE_BIS_BUCKET;



--This API should call BIS_BUCKET_PVT.UPDATE_BIS_BUCKET
PROCEDURE UPDATE_BIS_BUCKET (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  BIS_BUCKET_PVT.UPDATE_BIS_BUCKET(
    p_bis_bucket_rec => p_bis_bucket_rec
   ,x_return_status  => x_return_status
   ,x_error_tbl      => x_error_tbl
  );

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message(
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.UPDATE_BIS_BUCKET'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );

END UPDATE_BIS_BUCKET;



--This API should call BIS_BUCKET_PVT.DELETE_BIS_BUCKET
PROCEDURE DELETE_BIS_BUCKET (
  p_bucket_id   	IN BIS_BUCKET.bucket_id%TYPE	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_short_name		IN BIS_BUCKET.short_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_return_status      	OUT NOCOPY VARCHAR2
 ,x_error_tbl     	OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  BIS_BUCKET_PVT.DELETE_BIS_BUCKET(
    p_bucket_id	     => p_bucket_id
   ,p_short_name     => p_short_name
   ,x_return_status  => x_return_status
   ,x_error_tbl      => x_error_tbl
  );

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message(
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.DELETE_BIS_BUCKET'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );

END DELETE_BIS_BUCKET;



--This API should call BIS_BUCKET_PVT.RETRIEVE_BIS_BUCKET
PROCEDURE RETRIEVE_BIS_BUCKET (
  p_short_name		IN BIS_BUCKET.short_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_bis_bucket_rec	OUT NOCOPY BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status      	OUT NOCOPY VARCHAR2
 ,x_error_tbl          	OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  BIS_BUCKET_PVT.RETRIEVE_BIS_BUCKET(
    p_short_name     => p_short_name
   ,x_bis_bucket_rec => x_bis_bucket_rec
   ,x_return_status  => x_return_status
   ,x_error_tbl      => x_error_tbl
  );

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message(
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.RETRIEVE_BIS_BUCKET'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );

END RETRIEVE_BIS_BUCKET;
-- This API is called from LCT file
--=============================================================================
PROCEDURE LOAD_BIS_BUCKET (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status      	OUT NOCOPY VARCHAR2
 ,x_error_tbl          	OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) IS

CURSOR c_bkt_set IS
  SELECT 1
  FROM   bis_bucket
  WHERE  short_name = p_bis_bucket_rec.short_name;
  l_bucket_exists NUMBER := 0;
  l_bis_bucket_rec  BIS_BUCKET_PUB.bis_bucket_rec_type;
  l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_bis_bucket_rec := p_bis_bucket_rec;

  IF (c_bkt_set%ISOPEN) THEN
    CLOSE c_bkt_set;
  END IF;

  OPEN c_bkt_set;
  FETCH c_bkt_set INTO l_bucket_exists;
  IF (c_bkt_set%FOUND) THEN
    CLOSE c_bkt_set;
    BIS_BUCKET_PVT.UPDATE_BIS_BUCKET (
      p_bis_bucket_rec    => l_bis_bucket_rec
     ,x_return_status     => x_return_status
     ,x_error_tbl         => x_error_tbl
    );
  ELSE
    CLOSE c_bkt_set;
    BIS_BUCKET_PVT.CREATE_BIS_BUCKET (
      p_bis_bucket_rec    => l_bis_bucket_rec
     ,x_return_status     => x_return_status
     ,x_error_tbl         => x_error_tbl
    );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (c_bkt_set%ISOPEN) THEN
      CLOSE c_bkt_set;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RAISE FND_API.G_EXC_ERROR;

  WHEN OTHERS THEN
    IF (c_bkt_set%ISOPEN) THEN
      CLOSE c_bkt_set;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message(
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.LOAD_BIS_BUCKET'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LOAD_BIS_BUCKET;
--=============================================================================


PROCEDURE ADD_LANGUAGE
IS
BEGIN

   BIS_BUCKET_PVT.ADD_LANGUAGE;

END ADD_LANGUAGE;

END BIS_BUCKET_PUB;

/
