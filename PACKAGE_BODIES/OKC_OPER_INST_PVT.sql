--------------------------------------------------------
--  DDL for Package Body OKC_OPER_INST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OPER_INST_PVT" AS
/* $Header: OKCCCOPB.pls 120.0 2005/05/25 23:06:44 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  /*
  G_APP_NAME		 CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_PARENT_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE        CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_EXCEPTION_HALT_VALIDATION exception;
  NO_CONTRACT_FOUND exception;
  G_NO_UPDATE_ALLOWED_EXCEPTION exception;
  G_NO_UPDATE_ALLOWED CONSTANT VARCHAR2(200) := 'OKC_NO_UPDATE_ALLOWED';
  G_EXCEPTION_HALT_PROCESS exception;
  */
  ---------------------------------------------------------------------------

  PROCEDURE Create_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN  OKC_COP_PVT.copv_rec_type,
    x_copv_rec                     OUT NOCOPY  OKC_COP_PVT.copv_rec_type) IS

    l_copv_rec		OKC_COP_PVT.copv_rec_type := p_copv_rec;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

       OKC_COP_PVT.Insert_Row(
	       p_api_version	=> p_api_version,
	       p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_copv_rec		=> l_copv_rec,
            x_copv_rec		=> x_copv_rec);

  END Create_Class_Operation;

  PROCEDURE Create_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN  OKC_COP_PVT.copv_tbl_type,
    x_copv_tbl                     OUT NOCOPY  OKC_COP_PVT.copv_tbl_type) IS

  BEGIN

    OKC_COP_PVT.Insert_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_copv_tbl		=> p_copv_tbl,
      x_copv_tbl		=> x_copv_tbl);

  END Create_Class_Operation;

  PROCEDURE Update_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN OKC_COP_PVT.copv_rec_type,
    x_copv_rec                     OUT NOCOPY OKC_COP_PVT.copv_rec_type) IS

  BEGIN

    OKC_COP_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_copv_rec			=> p_copv_rec,
      x_copv_rec			=> x_copv_rec);

  END Update_Class_Operation;

  PROCEDURE Update_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN OKC_COP_PVT.copv_tbl_type,
    x_copv_tbl                     OUT NOCOPY OKC_COP_PVT.copv_tbl_type) IS

  BEGIN

    OKC_COP_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_copv_tbl			=> p_copv_tbl,
      x_copv_tbl			=> x_copv_tbl);

  END Update_Class_Operation;

  PROCEDURE Delete_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN OKC_COP_PVT.copv_rec_type) IS

  BEGIN
       OKC_COP_PVT.Delete_Row(
	 		p_api_version		=> p_api_version,
	 		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_copv_rec		=> p_copv_rec);

  END Delete_Class_Operation;

  PROCEDURE Delete_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN OKC_COP_PVT.copv_tbl_type) IS

  BEGIN

    OKC_COP_PVT.Delete_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_copv_tbl		=> p_copv_tbl);

  END Delete_Class_Operation;

  PROCEDURE Lock_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN OKC_COP_PVT.copv_rec_type) IS

  BEGIN

    OKC_COP_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_copv_rec		=> p_copv_rec);

  END Lock_Class_Operation;

  PROCEDURE Lock_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN OKC_COP_PVT.copv_tbl_type) IS

  BEGIN

    OKC_COP_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_copv_tbl		=> p_copv_tbl);

  END Lock_Class_Operation;

  PROCEDURE Validate_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN OKC_COP_PVT.copv_rec_type) IS

  BEGIN

    OKC_COP_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_copv_rec		=> p_copv_rec);

  END Validate_Class_Operation;

  PROCEDURE Validate_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN OKC_COP_PVT.copv_tbl_type) IS

  BEGIN

    OKC_COP_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_copv_tbl		=> p_copv_tbl);

  END Validate_Class_Operation;

  PROCEDURE Create_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN  OKC_OIE_PVT.oiev_rec_type,
    x_oiev_rec                     OUT NOCOPY  OKC_OIE_PVT.oiev_rec_type) IS

    l_oiev_rec		OKC_OIE_PVT.oiev_rec_type := p_oiev_rec;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

       OKC_OIE_PVT.Insert_Row(
	       p_api_version	=> p_api_version,
	       p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_oiev_rec		=> l_oiev_rec,
            x_oiev_rec		=> x_oiev_rec);

  END Create_Operation_Instance;

  PROCEDURE Create_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN  OKC_OIE_PVT.oiev_tbl_type,
    x_oiev_tbl                     OUT NOCOPY  OKC_OIE_PVT.oiev_tbl_type) IS

  BEGIN

    OKC_OIE_PVT.Insert_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_tbl		=> p_oiev_tbl,
      x_oiev_tbl		=> x_oiev_tbl);

  END Create_Operation_Instance;

  PROCEDURE Update_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN OKC_OIE_PVT.oiev_rec_type,
    x_oiev_rec                     OUT NOCOPY OKC_OIE_PVT.oiev_rec_type) IS

  BEGIN

    OKC_OIE_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_oiev_rec			=> p_oiev_rec,
      x_oiev_rec			=> x_oiev_rec);

  END Update_Operation_Instance;

  PROCEDURE Update_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN OKC_OIE_PVT.oiev_tbl_type,
    x_oiev_tbl                     OUT NOCOPY OKC_OIE_PVT.oiev_tbl_type) IS

  BEGIN

    OKC_OIE_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_oiev_tbl			=> p_oiev_tbl,
      x_oiev_tbl			=> x_oiev_tbl);

  END Update_Operation_Instance;

  PROCEDURE Delete_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN OKC_OIE_PVT.oiev_rec_type) IS

    l_olev_tbl 			   OKC_OPER_INST_PUB.olev_tbl_type;
    l_mrdv_tbl                     OKC_MRD_PVT.mrdv_tbl_type;
    i 				   NUMBER := 0;
    j 			           NUMBER := 0;

    Cursor ole_csr Is
		 SELECT id
		 FROM okc_operation_lines
		 WHERE oie_id = p_oiev_rec.id;

    Cursor ole1_csr Is
		 SELECT id
		 FROM okc_masschange_req_dtls
		 WHERE oie_id = p_oiev_rec.id;
  BEGIN
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
	  --
	  -- Delete all children (operation lines) before deleting instance
	  --
	  FOR ole_rec IN ole_csr
	  LOOP
		 i := i + 1;
           l_olev_tbl(i).ID := ole_rec.ID;
	  END LOOP;

          If (i > 0) Then
            OKC_OPER_INST_PUB.Delete_Operation_Line (
	         p_api_version		=> p_api_version,
	         p_init_msg_list	     => p_init_msg_list,
              x_return_status 	=> x_return_status,
              x_msg_count     	=> x_msg_count,
              x_msg_data      	=> x_msg_data,
              p_olev_tbl		     => l_olev_tbl);
	    End if;


        --
	-- Delete all children (masschange) before deleting instance
	--

        If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
           FOR oie_rec IN ole1_csr
           LOOP
	       j := j + 1;
               l_mrdv_tbl(j).ID := oie_rec.ID;
	   END LOOP;

           If (j > 0) Then
               -- call procedure in complex API

               OKC_OPER_INST_PUB.Delete_Masschange_Dtls (
	           p_api_version		=> p_api_version,
	           p_init_msg_list	     => p_init_msg_list,
                x_return_status 	=> x_return_status,
                x_msg_count     	=> x_msg_count,
                x_msg_data      	=> x_msg_data,
                p_mrdv_tbl		     => l_mrdv_tbl);
	   End if;
        End If;


	If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
              OKC_OIE_PVT.Delete_Row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_oiev_rec		=> p_oiev_rec);
        End If;
  END Delete_Operation_Instance;

  PROCEDURE Delete_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN OKC_OIE_PVT.oiev_tbl_type) IS

  BEGIN

    OKC_OIE_PVT.Delete_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_tbl		=> p_oiev_tbl);

  END Delete_Operation_Instance;

  PROCEDURE Lock_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN OKC_OIE_PVT.oiev_rec_type) IS

  BEGIN

    OKC_OIE_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_rec		=> p_oiev_rec);

  END Lock_Operation_Instance;

  PROCEDURE Lock_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN OKC_OIE_PVT.oiev_tbl_type) IS

  BEGIN

    OKC_OIE_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_tbl		=> p_oiev_tbl);

  END Lock_Operation_Instance;

  PROCEDURE Validate_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN OKC_OIE_PVT.oiev_rec_type) IS

  BEGIN

    OKC_OIE_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_rec		=> p_oiev_rec);

  END Validate_Operation_Instance;

  PROCEDURE Validate_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN OKC_OIE_PVT.oiev_tbl_type) IS

  BEGIN

    OKC_OIE_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_tbl		=> p_oiev_tbl);

  END Validate_Operation_Instance;

  PROCEDURE Create_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN  OKC_OLE_PVT.olev_rec_type,
    x_olev_rec                     OUT NOCOPY  OKC_OLE_PVT.olev_rec_type) IS

    l_olev_rec		OKC_OLE_PVT.olev_rec_type := p_olev_rec;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

       OKC_OLE_PVT.Insert_Row(
	       p_api_version	=> p_api_version,
	       p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_olev_rec		=> l_olev_rec,
            x_olev_rec		=> x_olev_rec);

  END Create_Operation_Line;

  PROCEDURE Create_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN  OKC_OLE_PVT.olev_tbl_type,
    x_olev_tbl                     OUT NOCOPY  OKC_OLE_PVT.olev_tbl_type) IS

  BEGIN

    OKC_OLE_PVT.Insert_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_olev_tbl		=> p_olev_tbl,
      x_olev_tbl		=> x_olev_tbl);

  END Create_Operation_Line;

  PROCEDURE Update_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN OKC_OLE_PVT.olev_rec_type,
    x_olev_rec                     OUT NOCOPY OKC_OLE_PVT.olev_rec_type) IS

  BEGIN

    OKC_OLE_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_olev_rec			=> p_olev_rec,
      x_olev_rec			=> x_olev_rec);

  END Update_Operation_Line;

  PROCEDURE Update_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN OKC_OLE_PVT.olev_tbl_type,
    x_olev_tbl                     OUT NOCOPY OKC_OLE_PVT.olev_tbl_type) IS

  BEGIN

    OKC_OLE_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_olev_tbl			=> p_olev_tbl,
      x_olev_tbl			=> x_olev_tbl);

  END Update_Operation_Line;

  PROCEDURE Delete_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN OKC_OLE_PVT.olev_rec_type) IS

    l_mrdv_tbl                     OKC_MRD_PVT.mrdv_tbl_type;
    j 				   NUMBER := 0;

    Cursor ole_csr Is
		SELECT object_chr_id, subject_chr_id, object_cle_id, subject_cle_id
		FROM okc_operation_lines
		WHERE id = p_olev_rec.ID
		AND active_yn = 'Y';

   Cursor ole1_csr Is
		 SELECT id
		 FROM okc_masschange_req_dtls
		 WHERE ole_id = p_olev_rec.ID;

  BEGIN
	 --
         -- clear renewal links before deleting operation line entry
	 -- If object line id is null, clear header's date_renewed
	 -- If object line id is not null, clear line's date_renewed
	 --
	 FOR ole_rec IN ole_csr
	 LOOP
		If (ole_rec.object_cle_id is not null) Then
		    UPDATE okc_k_lines_b
		    SET date_renewed = null
		    WHERE id = ole_rec.object_cle_id;
		Elsif (ole_rec.object_chr_id is not null AND
			  ole_rec.subject_cle_id is null) Then
		    UPDATE okc_k_headers_b
		    SET date_renewed = null
		    WHERE id = ole_rec.object_chr_id;
		End If;
	 END LOOP;

        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        --
	-- Delete all children (masschange) before deleting operation line
	--

        FOR oie_rec IN ole1_csr
	  LOOP
	     j := j + 1;
             l_mrdv_tbl(j).ID := oie_rec.ID;
	  END LOOP;

        If (j > 0) Then
            -- call procedure in complex API

            OKC_OPER_INST_PUB.Delete_Masschange_Dtls (
	        p_api_version		=> p_api_version,
	        p_init_msg_list	     => p_init_msg_list,
                x_return_status 	=> x_return_status,
                x_msg_count     	=> x_msg_count,
                x_msg_data      	=> x_msg_data,
                p_mrdv_tbl		     => l_mrdv_tbl);
	 End if;

         If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then

            OKC_OLE_PVT.Delete_Row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_olev_rec		=> p_olev_rec);
         End If;
  END Delete_Operation_Line;

  PROCEDURE Delete_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN OKC_OLE_PVT.olev_tbl_type) IS

  BEGIN

    OKC_OLE_PVT.Delete_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_olev_tbl		=> p_olev_tbl);

  END Delete_Operation_Line;

  PROCEDURE Lock_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN OKC_OLE_PVT.olev_rec_type) IS

  BEGIN

    OKC_OLE_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_olev_rec		=> p_olev_rec);

  END Lock_Operation_Line;

  PROCEDURE Lock_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN OKC_OLE_PVT.olev_tbl_type) IS

  BEGIN

    OKC_OLE_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_olev_tbl		=> p_olev_tbl);

  END Lock_Operation_Line;

  PROCEDURE Validate_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN OKC_OLE_PVT.olev_rec_type) IS

  BEGIN

    OKC_OLE_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_olev_rec		=> p_olev_rec);

  END Validate_Operation_Line;

  PROCEDURE Validate_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN OKC_OLE_PVT.olev_tbl_type) IS

  BEGIN

    OKC_OLE_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_olev_tbl		=> p_olev_tbl);

  END Validate_Operation_Line;

  PROCEDURE Create_Masschange_Dtls  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN  OKC_MRD_PVT.mrdv_rec_type,
    x_mrdv_rec                     OUT NOCOPY  OKC_MRD_PVT.mrdv_rec_type) IS

    l_mrdv_rec		OKC_MRD_PVT.mrdv_rec_type := p_mrdv_rec;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

       OKC_MRD_PVT.Insert_Row(
	    p_api_version	=> p_api_version,
	    p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_mrdv_rec		=> l_mrdv_rec,
            x_mrdv_rec		=> x_mrdv_rec);

  END Create_Masschange_Dtls;

  PROCEDURE Create_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN  OKC_MRD_PVT.mrdv_tbl_type,
    x_mrdv_tbl                     OUT NOCOPY  OKC_MRD_PVT.mrdv_tbl_type) IS

  BEGIN

    OKC_MRD_PVT.Insert_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_mrdv_tbl	=> p_mrdv_tbl,
      x_mrdv_tbl	=> x_mrdv_tbl);

  END Create_Masschange_Dtls;

  PROCEDURE Update_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN OKC_MRD_PVT.mrdv_rec_type,
    x_mrdv_rec                     OUT NOCOPY OKC_MRD_PVT.mrdv_rec_type) IS

  BEGIN

    OKC_MRD_PVT.Update_Row(
      p_api_version		=> p_api_version,
      p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_mrdv_rec		=> p_mrdv_rec,
      x_mrdv_rec		=> x_mrdv_rec);

  END Update_Masschange_Dtls;

  PROCEDURE Update_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN OKC_MRD_PVT.mrdv_tbl_type,
    x_mrdv_tbl                     OUT NOCOPY OKC_MRD_PVT.mrdv_tbl_type) IS

  BEGIN

    OKC_MRD_PVT.Update_Row(
      p_api_version		=> p_api_version,
      p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_mrdv_tbl		=> p_mrdv_tbl,
      x_mrdv_tbl		=> x_mrdv_tbl);

  END Update_Masschange_Dtls;

  PROCEDURE Delete_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN OKC_MRD_PVT.mrdv_rec_type) IS

  BEGIN
       OKC_MRD_PVT.Delete_Row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_mrdv_rec		=> p_mrdv_rec);

  END Delete_Masschange_Dtls;

  PROCEDURE Delete_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN OKC_MRD_PVT.mrdv_tbl_type) IS

  BEGIN

    OKC_MRD_PVT.Delete_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_mrdv_tbl	=> p_mrdv_tbl);

  END Delete_Masschange_Dtls;

  PROCEDURE Lock_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN OKC_MRD_PVT.mrdv_rec_type) IS

  BEGIN

    OKC_MRD_PVT.Lock_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_mrdv_rec	=> p_mrdv_rec);

  END Lock_Masschange_Dtls;

  PROCEDURE Lock_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN OKC_MRD_PVT.mrdv_tbl_type) IS

  BEGIN

    OKC_MRD_PVT.Lock_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_mrdv_tbl	=> p_mrdv_tbl);

  END Lock_Masschange_Dtls;

  PROCEDURE Validate_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN OKC_MRD_PVT.mrdv_rec_type) IS

  BEGIN

    OKC_MRD_PVT.Validate_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_mrdv_rec	=> p_mrdv_rec);

  END Validate_Masschange_Dtls;

  PROCEDURE Validate_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN OKC_MRD_PVT.mrdv_tbl_type) IS

  BEGIN

    OKC_MRD_PVT.Validate_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_mrdv_tbl	=> p_mrdv_tbl);

  END Validate_Masschange_Dtls;
END OKC_OPER_INST_PVT;

/
