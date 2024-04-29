--------------------------------------------------------
--  DDL for Package Body OKL_ACCT_GEN_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCT_GEN_RULE_PVT" AS
/* $Header: OKLRACGB.pls 115.8 2002/11/30 08:42:02 spillaip noship $ */


PROCEDURE GET_RULE_LINES_COUNT(p_api_version        IN     NUMBER,
                               p_init_msg_list      IN     VARCHAR2,
                               x_return_status      OUT    NOCOPY VARCHAR2,
                               x_msg_count          OUT    NOCOPY NUMBER,
                               x_msg_data           OUT    NOCOPY VARCHAR2,
      		               p_ae_line_type       IN     VARCHAR2,
                               x_line_count         OUT NOCOPY    NUMBER)

IS

  l_api_name          CONSTANT VARCHAR2(40) := 'GET_RULE_LINES_COUNT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_acc_lines         aulv_tbl_type;
  i                   NUMBER := 0;
  l_set_of_books_id   NUMBER ;
  l_agr_id            NUMBER;
  l_line_count        NUMBER := 0;

  l_array_of_segments OKL_ACCOUNTING_UTIL.seg_num_name_type;


  CURSOR acg_csr(v_set_of_books_id NUMBER) IS

  SELECT ID
  FROM OKL_ACC_GEN_RULES_V
  WHERE ae_line_type    = p_ae_line_type
  AND   set_of_books_id = v_set_of_books_id;



  CURSOR acgl_csr(v_agr_id NUMBER) IS
  SELECT  ID
         ,SEGMENT
 	 ,SEGMENT_NUMBER
         ,AGR_ID
         ,SOURCE
 	 ,CONSTANTS
 	 ,OBJECT_VERSION_NUMBER
 	 ,ATTRIBUTE_CATEGORY
 	 ,ATTRIBUTE1
 	 ,ATTRIBUTE2
 	 ,ATTRIBUTE3
 	 ,ATTRIBUTE4
 	 ,ATTRIBUTE5
 	 ,ATTRIBUTE6
 	 ,ATTRIBUTE7
 	 ,ATTRIBUTE8
 	 ,ATTRIBUTE9
 	 ,ATTRIBUTE10
 	 ,ATTRIBUTE11
 	 ,ATTRIBUTE12
 	 ,ATTRIBUTE13
 	 ,ATTRIBUTE14
 	 ,ATTRIBUTE15
 	 ,CREATED_BY
 	 ,CREATION_DATE
 	 ,LAST_UPDATED_BY
 	 ,LAST_UPDATE_DATE
 	 ,LAST_UPDATE_LOGIN
  FROM  OKL_ACC_GEN_RUL_LNS_V
  WHERE agr_id = v_agr_id;

  acgl_rec  acgl_csr%ROWTYPE;



BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

-- Get set of books id

   l_set_of_books_id  := OKL_ACCOUNTING_UTIL.GET_SET_OF_BOOKS_ID;


-- Check if the record exists in the Header Table.

  OPEN acg_csr(l_set_of_books_id);
  FETCH acg_csr INTO l_agr_id;
  IF (acg_csr%NOTFOUND) THEN

      OKL_ACCOUNTING_UTIL.GET_ACCOUNTING_SEGMENT(p_segment_array => l_array_of_segments);
      l_line_count := l_array_of_segments.seg_num.COUNT;

  ELSE

      i := 0;

      FOR acgl_rec IN acgl_csr(l_agr_id)

      LOOP

	 i := i + 1;

      END LOOP;

      l_line_count := i;

  END IF;

  CLOSE acg_csr;

  x_line_count := l_line_count;

  EXCEPTION

    WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END GET_RULE_LINES_COUNT;



PROCEDURE GET_RULE_LINES(p_api_version        IN     NUMBER,
                         p_init_msg_list      IN     VARCHAR2,
                         x_return_status      OUT    NOCOPY VARCHAR2,
                         x_msg_count          OUT    NOCOPY NUMBER,
                         x_msg_data           OUT    NOCOPY VARCHAR2,
		         p_ae_line_type       IN     VARCHAR2,
                         x_acc_lines          OUT NOCOPY    ACCT_TBL_TYPE)

IS

  l_api_name          CONSTANT VARCHAR2(40) := 'GET_RULE_LINES';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_acc_lines         acct_tbl_type;
  i                   NUMBER := 0;
  l_set_of_books_id   NUMBER ;
  l_agr_id            NUMBER;

  l_array_of_segments OKL_ACCOUNTING_UTIL.seg_num_name_type;


  CURSOR acg_csr(v_set_of_books_id NUMBER) IS

  SELECT ID
  FROM OKL_ACC_GEN_RULES_V
  WHERE ae_line_type    = p_ae_line_type
  AND   set_of_books_id = v_set_of_books_id;



  CURSOR acgl_csr(v_agr_id NUMBER) IS
  SELECT  ID
         ,SEGMENT
 	 ,SEGMENT_NUMBER
         ,AGR_ID
         ,SOURCE
 	 ,CONSTANTS
 	 ,OBJECT_VERSION_NUMBER
 	 ,ATTRIBUTE_CATEGORY
 	 ,ATTRIBUTE1
 	 ,ATTRIBUTE2
 	 ,ATTRIBUTE3
 	 ,ATTRIBUTE4
 	 ,ATTRIBUTE5
 	 ,ATTRIBUTE6
 	 ,ATTRIBUTE7
 	 ,ATTRIBUTE8
 	 ,ATTRIBUTE9
 	 ,ATTRIBUTE10
 	 ,ATTRIBUTE11
 	 ,ATTRIBUTE12
 	 ,ATTRIBUTE13
 	 ,ATTRIBUTE14
 	 ,ATTRIBUTE15
 	 ,CREATED_BY
 	 ,CREATION_DATE
 	 ,LAST_UPDATED_BY
 	 ,LAST_UPDATE_DATE
 	 ,LAST_UPDATE_LOGIN
  FROM  OKL_ACC_GEN_RUL_LNS_V
  WHERE agr_id = v_agr_id;

  acgl_rec  acgl_csr%ROWTYPE;




BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

-- Get set of books id and ORG id

  l_set_of_books_id  := OKL_ACCOUNTING_UTIL.GET_SET_OF_BOOKS_ID;


-- Check if the record exists in the Header Table.

  OPEN acg_csr(l_set_of_books_id);
  FETCH acg_csr INTO l_agr_id;
  IF (acg_csr%NOTFOUND) THEN

      OKL_ACCOUNTING_UTIL.GET_ACCOUNTING_SEGMENT(p_segment_array => l_array_of_segments);

      FOR i IN 1..l_array_of_segments.seg_num.COUNT

      LOOP
	  l_acc_lines(i).SEGMENT_NUMBER := l_array_of_segments.seg_num(i);
	  l_acc_lines(i).SEGMENT        := l_array_of_segments.seg_name(i);
	  l_acc_lines(i).SEGMENT_DESC   := l_array_of_segments.seg_desc(i);
	  l_acc_lines(i).ae_line_type   := p_ae_line_type;
      END LOOP;

  ELSE

      i := 0;

      FOR acgl_rec IN acgl_csr(l_agr_id)

      LOOP

	 i := i + 1;
	 l_acc_lines(i).ID             	 	  := acgl_rec.ID;
	 l_acc_lines(i).AE_LINE_TYPE              := p_ae_line_type;
         l_acc_lines(i).SEGMENT     		  := acgl_rec.SEGMENT;
         l_acc_lines(i).SEGMENT_DESC
                 := OKL_ACCOUNTING_UTIL.get_segment_desc(acgl_rec.SEGMENT);
         l_acc_lines(i).SEGMENT_NUMBER  	  := acgl_rec.SEGMENT_NUMBER;
         l_acc_lines(i).AGR_ID  		  := acgl_rec.AGR_ID;
         l_acc_lines(i).SOURCE  		  := acgl_rec.SOURCE;
  	 l_acc_lines(i).CONSTANTS  		  := acgl_rec.CONSTANTS;
         l_acc_lines(i).OBJECT_VERSION_NUMBER     := acgl_rec.OBJECT_VERSION_NUMBER;
  	 l_acc_lines(i).ATTRIBUTE_CATEGORY        := acgl_rec.ATTRIBUTE_CATEGORY;
  	 l_acc_lines(i).ATTRIBUTE1  		  := acgl_rec.ATTRIBUTE1;
  	 l_acc_lines(i).ATTRIBUTE2  		  := acgl_rec.ATTRIBUTE2;
  	 l_acc_lines(i).ATTRIBUTE3  		  := acgl_rec.ATTRIBUTE3;
  	 l_acc_lines(i).ATTRIBUTE4  		  := acgl_rec.ATTRIBUTE4;
  	 l_acc_lines(i).ATTRIBUTE5  		  := acgl_rec.ATTRIBUTE5;
  	 l_acc_lines(i).ATTRIBUTE6  		  := acgl_rec.ATTRIBUTE6;
  	 l_acc_lines(i).ATTRIBUTE7  		  := acgl_rec.ATTRIBUTE7;
  	 l_acc_lines(i).ATTRIBUTE8  		  := acgl_rec.ATTRIBUTE8;
  	 l_acc_lines(i).ATTRIBUTE9  		  := acgl_rec.ATTRIBUTE9;
  	 l_acc_lines(i).ATTRIBUTE10  		  := acgl_rec.ATTRIBUTE10;
  	 l_acc_lines(i).ATTRIBUTE11  		  := acgl_rec.ATTRIBUTE11;
  	 l_acc_lines(i).ATTRIBUTE12  		  := acgl_rec.ATTRIBUTE12;
  	 l_acc_lines(i).ATTRIBUTE13  		  := acgl_rec.ATTRIBUTE13;
  	 l_acc_lines(i).ATTRIBUTE14  		  := acgl_rec.ATTRIBUTE14;
  	 l_acc_lines(i).ATTRIBUTE15  		  := acgl_rec.ATTRIBUTE15;
  	 l_acc_lines(i).CREATED_BY  		  := acgl_rec.CREATED_BY;
  	 l_acc_lines(i).CREATION_DATE  		  := acgl_rec.CREATION_DATE;
  	 l_acc_lines(i).LAST_UPDATED_BY  	  := acgl_rec.LAST_UPDATED_BY;
  	 l_acc_lines(i).LAST_UPDATE_DATE  	  := acgl_rec.LAST_UPDATE_DATE;
  	 l_acc_lines(i).LAST_UPDATE_LOGIN  	  := acgl_rec.LAST_UPDATE_LOGIN;

      END LOOP;

  END IF;

  CLOSE acg_csr;

  x_acc_lines := l_acc_lines;


  EXCEPTION

    WHEN OTHERS THEN

        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END GET_RULE_LINES;


PROCEDURE MOVE_ACC_TO_AUL(p_acc_lines IN  acct_tbl_type,
                          p_aulv_tbl  OUT NOCOPY aulv_tbl_type)
IS

i  NUMBER := 0;

BEGIN

   FOR i IN 1..p_acc_lines.COUNT

   LOOP

        p_aulv_tbl(i).ID                     := p_acc_lines(i).ID;
        p_aulv_tbl(i).SEGMENT                := p_acc_lines(i).SEGMENT;
        p_aulv_tbl(i).SEGMENT_NUMBER         := p_acc_lines(i).SEGMENT_NUMBER;
        p_aulv_tbl(i).AGR_ID                 := p_acc_lines(i).AGR_ID;
        p_aulv_tbl(i).SOURCE                 := p_acc_lines(i).SOURCE;
        p_aulv_tbl(i).OBJECT_VERSION_NUMBER  := p_acc_lines(i).OBJECT_VERSION_NUMBER;
        p_aulv_tbl(i).CONSTANTS              := p_acc_lines(i).CONSTANTS;
        p_aulv_tbl(i).ATTRIBUTE_CATEGORY     := p_acc_lines(i).ATTRIBUTE_CATEGORY;
        p_aulv_tbl(i).ATTRIBUTE1             := p_acc_lines(i).ATTRIBUTE1;
        p_aulv_tbl(i).ATTRIBUTE2             := p_acc_lines(i).ATTRIBUTE2;
        p_aulv_tbl(i).ATTRIBUTE3             := p_acc_lines(i).ATTRIBUTE3;
        p_aulv_tbl(i).ATTRIBUTE4             := p_acc_lines(i).ATTRIBUTE4;
        p_aulv_tbl(i).ATTRIBUTE5             := p_acc_lines(i).ATTRIBUTE5;
        p_aulv_tbl(i).ATTRIBUTE6             := p_acc_lines(i).ATTRIBUTE6;
        p_aulv_tbl(i).ATTRIBUTE7             := p_acc_lines(i).ATTRIBUTE7;
        p_aulv_tbl(i).ATTRIBUTE8             := p_acc_lines(i).ATTRIBUTE8;
        p_aulv_tbl(i).ATTRIBUTE9             := p_acc_lines(i).ATTRIBUTE9;
        p_aulv_tbl(i).ATTRIBUTE10            := p_acc_lines(i).ATTRIBUTE10;
        p_aulv_tbl(i).ATTRIBUTE11            := p_acc_lines(i).ATTRIBUTE11;
        p_aulv_tbl(i).ATTRIBUTE12            := p_acc_lines(i).ATTRIBUTE12;
        p_aulv_tbl(i).ATTRIBUTE13            := p_acc_lines(i).ATTRIBUTE13;
        p_aulv_tbl(i).ATTRIBUTE14            := p_acc_lines(i).ATTRIBUTE14;
        p_aulv_tbl(i).ATTRIBUTE15            := p_acc_lines(i).ATTRIBUTE15;
        p_aulv_tbl(i).CREATED_BY             := p_acc_lines(i).CREATED_BY;
        p_aulv_tbl(i).CREATION_DATE          := p_acc_lines(i).CREATION_DATE;
        p_aulv_tbl(i).LAST_UPDATED_BY        := p_acc_lines(i).LAST_UPDATED_BY;
        p_aulv_tbl(i).LAST_UPDATE_DATE       := p_acc_lines(i).LAST_UPDATE_DATE;
        p_aulv_tbl(i).LAST_UPDATE_LOGIN      := p_acc_lines(i).LAST_UPDATE_LOGIN;

      END LOOP;

END MOVE_ACC_TO_AUL;


PROCEDURE MOVE_AUL_TO_ACC(p_aulv_tbl   IN  aulv_tbl_type,
                          p_acc_lines  OUT NOCOPY acct_tbl_type)
IS

i  NUMBER := 0;

BEGIN

   FOR i IN 1..p_acc_lines.COUNT

   LOOP

        p_acc_lines(i).ID                     := p_aulv_tbl(i).ID;
        p_acc_lines(i).SEGMENT                := p_aulv_tbl(i).SEGMENT;
        p_acc_lines(i).SEGMENT_DESC
                 := OKL_ACCOUNTING_UTIL.get_segment_desc(p_aulv_tbl(i).SEGMENT);
        p_acc_lines(i).SEGMENT_NUMBER         := p_aulv_tbl(i).SEGMENT_NUMBER;
        p_acc_lines(i).AGR_ID                 := p_aulv_tbl(i).AGR_ID;
        p_acc_lines(i).SOURCE                 := p_aulv_tbl(i).SOURCE;
        p_acc_lines(i).OBJECT_VERSION_NUMBER  := p_aulv_tbl(i).OBJECT_VERSION_NUMBER;
        p_acc_lines(i).CONSTANTS              := p_aulv_tbl(i).CONSTANTS;
        p_acc_lines(i).ATTRIBUTE_CATEGORY     := p_aulv_tbl(i).ATTRIBUTE_CATEGORY;
        p_acc_lines(i).ATTRIBUTE1             := p_aulv_tbl(i).ATTRIBUTE1;
        p_acc_lines(i).ATTRIBUTE2             := p_aulv_tbl(i).ATTRIBUTE2;
        p_acc_lines(i).ATTRIBUTE3             := p_aulv_tbl(i).ATTRIBUTE3;
        p_acc_lines(i).ATTRIBUTE4             := p_aulv_tbl(i).ATTRIBUTE4;
        p_acc_lines(i).ATTRIBUTE5             := p_aulv_tbl(i).ATTRIBUTE5;
        p_acc_lines(i).ATTRIBUTE6             := p_aulv_tbl(i).ATTRIBUTE6;
        p_acc_lines(i).ATTRIBUTE7             := p_aulv_tbl(i).ATTRIBUTE7;
        p_acc_lines(i).ATTRIBUTE8             := p_aulv_tbl(i).ATTRIBUTE8;
        p_acc_lines(i).ATTRIBUTE9             := p_aulv_tbl(i).ATTRIBUTE9;
        p_acc_lines(i).ATTRIBUTE10            := p_aulv_tbl(i).ATTRIBUTE10;
        p_acc_lines(i).ATTRIBUTE11            := p_aulv_tbl(i).ATTRIBUTE11;
        p_acc_lines(i).ATTRIBUTE12            := p_aulv_tbl(i).ATTRIBUTE12;
        p_acc_lines(i).ATTRIBUTE13            := p_aulv_tbl(i).ATTRIBUTE13;
        p_acc_lines(i).ATTRIBUTE14            := p_aulv_tbl(i).ATTRIBUTE14;
        p_acc_lines(i).ATTRIBUTE15            := p_aulv_tbl(i).ATTRIBUTE15;
        p_acc_lines(i).CREATED_BY             := p_aulv_tbl(i).CREATED_BY;
        p_acc_lines(i).CREATION_DATE          := p_aulv_tbl(i).CREATION_DATE;
        p_acc_lines(i).LAST_UPDATED_BY        := p_aulv_tbl(i).LAST_UPDATED_BY;
        p_acc_lines(i).LAST_UPDATE_DATE       := p_aulv_tbl(i).LAST_UPDATE_DATE;
        p_acc_lines(i).LAST_UPDATE_LOGIN      := p_aulv_tbl(i).LAST_UPDATE_LOGIN;

      END LOOP;

END MOVE_AUL_TO_ACC;



PROCEDURE UPDT_RULE_LINES(p_api_version       IN     NUMBER,
                          p_init_msg_list     IN     VARCHAR2,
                          x_return_status     OUT    NOCOPY VARCHAR2,
                          x_msg_count         OUT    NOCOPY NUMBER,
                          x_msg_data          OUT    NOCOPY VARCHAR2,
                          p_acc_lines         IN     ACCT_TBL_TYPE,
			  x_acc_lines         OUT NOCOPY    ACCT_TBL_TYPE)

IS


CURSOR acg_csr(v_set_of_books_id NUMBER,
               v_ae_line_type    VARCHAR2) IS

SELECT '1'
FROM OKL_ACC_GEN_RULES_V
WHERE ae_line_type    = v_ae_line_type
AND   set_of_books_id = v_set_of_books_id;

l_dummy           VARCHAR2(1);
l_api_version     NUMBER := 1.0;
l_init_msg_list   VARCHAR2(1) := OKL_API.G_FALSE;
l_msg_count       NUMBER := 0;
l_msg_data        VARCHAR2(2000);
l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_ae_line_type    OKL_ACCT_GEN_RULES_V.AE_LINE_TYPE%TYPE;

l_aulv_tbl_in     AULV_TBL_TYPE;
l_aulv_tbl_out    AULV_TBL_TYPE;

l_agrv_rec_in     AGRV_REC_TYPE;
l_agrv_rec_out    AGRV_REC_TYPE;
l_set_of_books_id   NUMBER ;
i                 NUMBER := 0;
l_api_name         CONSTANT VARCHAR2(40) := 'UPDT_RULE_LINES';

BEGIN
-- Added by Santonyr 13-Aug-2002
-- Fixed bug 2500771

  l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Get set of books id and ORG id

  l_set_of_books_id  := OKL_ACCOUNTING_UTIL.GET_SET_OF_BOOKS_ID;
  l_ae_line_type     := p_acc_lines(1).ae_line_type;


  MOVE_ACC_TO_AUL(p_acc_lines => p_acc_lines,
                  p_aulv_tbl  => l_aulv_tbl_in);


  OPEN acg_csr(l_set_of_books_id,
               l_ae_line_type);

  FETCH acg_csr INTO l_dummy;

  IF (acg_csr%NOTFOUND) THEN


      l_agrv_rec_in.ae_line_type := l_ae_line_type;

      OKL_ACC_GEN_RULE_PUB.create_acc_gen_rule(p_api_version       => l_api_version,
                                               p_init_msg_list     => l_init_msg_list,
                                               x_return_status     => l_return_status,
                                               x_msg_count         => l_msg_count,
                                               x_msg_data          => l_msg_data,
                                               p_agrv_rec          => l_agrv_rec_in,
                                               p_aulv_tbl          => l_aulv_tbl_in,
                                               x_agrv_rec          => l_agrv_rec_out,
                                               x_aulv_tbl          => l_aulv_tbl_out);




  ELSE


      OKL_ACC_GEN_RULE_PUB.update_acc_gen_rule_lns(p_api_version       => l_api_version,
                                                   p_init_msg_list     => l_init_msg_list,
                                                   x_return_status     => l_return_status,
                                                   x_msg_count         => l_msg_count,
                                                   x_msg_data          => l_msg_data,
                                                   p_aulv_tbl          => l_aulv_tbl_in,
                                                   x_aulv_tbl          => l_aulv_tbl_out);



  END IF;


  CLOSE acg_csr;

  x_return_status := l_return_status;
  x_msg_data      := l_msg_data;
  x_msg_count     := l_msg_count;

  MOVE_AUL_TO_ACC(l_aulv_tbl_out,
                  x_acc_lines);

-- Added by Santonyr 13-Aug-2002
-- Fixed bug 2500771

  x_return_status := l_return_status;
  Okl_Api.end_activity(x_msg_count, x_msg_data);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                      ,g_pkg_name
                                                      ,'OTHERS'
                                                      ,x_msg_count
                                                      ,x_msg_data
                                                      ,'_PVT');


END UPDT_RULE_LINES;


END OKL_ACCT_GEN_RULE_PVT;

/
