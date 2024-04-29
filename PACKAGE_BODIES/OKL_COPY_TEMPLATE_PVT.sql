--------------------------------------------------------
--  DDL for Package Body OKL_COPY_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_COPY_TEMPLATE_PVT" AS
/* $Header: OKLRTLCB.pls 120.2 2006/07/11 10:05:16 dkagrawa noship $ */


PROCEDURE COPY_TEMPLATES(p_api_version                IN         NUMBER,
                         p_init_msg_list              IN         VARCHAR2,
                         x_return_status              OUT        NOCOPY VARCHAR2,
                         x_msg_count                  OUT        NOCOPY NUMBER,
                         x_msg_data                   OUT        NOCOPY VARCHAR2,
						 p_aes_id_from                IN         NUMBER,
						 p_aes_id_to                  IN         NUMBER)

IS


l_return_status    VARCHAR2(1);
l_api_name         VARCHAR2(30) := 'COPY_TEMPLATES';
l_init_msg_list    VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_api_version      NUMBER := 1.0;

i                  NUMBER := 0;

l_overall_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

l_avlv_rec_in      AVLV_REC_TYPE;
l_avlv_rec_out     AVLV_REC_TYPE;

l_atlv_tbl_in      ATLV_TBL_TYPE;
l_atlv_tbl_out     ATLV_TBL_TYPE;



CURSOR avl_csr(v_aes_id NUMBER) IS
SELECT   ID
        ,OBJECT_VERSION_NUMBER
        ,TRY_ID
        ,AES_ID
        ,STY_ID
        ,FMA_ID
        ,SET_OF_BOOKS_ID
        ,FAC_CODE
        ,SYT_CODE
        -- Added code by HKPATEL for Bug# 2943310
        ,INV_CODE
        -- Added code ends here
        ,POST_TO_GL
        ,ADVANCE_ARREARS
        ,MEMO_YN
        ,PRIOR_YEAR_YN
        ,NAME
        ,DESCRIPTION
        ,VERSION
        ,FACTORING_SYND_FLAG
        ,START_DATE
        ,END_DATE
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
        ,ORG_ID
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
FROM OKL_AE_TEMPLATES
WHERE aes_id = v_aes_id;


CURSOR atl_csr(v_avl_id NUMBER) IS
SELECT  ID
       ,SEQUENCE_NUMBER
       ,AVL_ID
       ,CODE_COMBINATION_ID
       ,AE_LINE_TYPE
       ,CRD_CODE
       ,OBJECT_VERSION_NUMBER
       ,ACCOUNT_BUILDER_YN
       ,DESCRIPTION
       ,PERCENTAGE
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
       ,ORG_ID
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATE_LOGIN
FROM OKL_AE_TMPT_LNES
WHERE avl_id = v_avl_id;



BEGIN

   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   FOR avl_rec IN avl_csr(p_aes_id_from)

   LOOP

        l_avlv_rec_in.TRY_ID                        := avl_rec.TRY_ID;
        l_avlv_rec_in.STY_ID                        := avl_rec.STY_ID;
        l_avlv_rec_in.FMA_ID                        := avl_rec.FMA_ID;
        l_avlv_rec_in.FAC_CODE                      := avl_rec.FAC_CODE;
        l_avlv_rec_in.SYT_CODE                      := avl_rec.SYT_CODE;
        -- Added code by HKPATEL for Bug# 2943310
        l_avlv_rec_in.INV_CODE                      := avl_rec.INV_CODE;
        -- Added code ends here
        l_avlv_rec_in.POST_TO_GL                    := avl_rec.POST_TO_GL;
        l_avlv_rec_in.ADVANCE_ARREARS               := avl_rec.ADVANCE_ARREARS;
        l_avlv_rec_in.MEMO_YN                       := avl_rec.MEMO_YN;
        l_avlv_rec_in.PRIOR_YEAR_YN                 := avl_rec.PRIOR_YEAR_YN;
        l_avlv_rec_in.DESCRIPTION                   := avl_rec.DESCRIPTION;
        l_avlv_rec_in.VERSION                       := avl_rec.VERSION;
        l_avlv_rec_in.FACTORING_SYND_FLAG           := avl_rec.FACTORING_SYND_FLAG;
        l_avlv_rec_in.START_DATE                    := avl_rec.START_DATE;
        l_avlv_rec_in.END_DATE                      := avl_rec.END_DATE;
        l_avlv_rec_in.ATTRIBUTE_CATEGORY            := avl_rec.ATTRIBUTE_CATEGORY;
        l_avlv_rec_in.ATTRIBUTE1                    := avl_rec.ATTRIBUTE1;
        l_avlv_rec_in.ATTRIBUTE2                    := avl_rec.ATTRIBUTE2;
        l_avlv_rec_in.ATTRIBUTE3                    := avl_rec.ATTRIBUTE3;
        l_avlv_rec_in.ATTRIBUTE4                    := avl_rec.ATTRIBUTE4;
        l_avlv_rec_in.ATTRIBUTE5                    := avl_rec.ATTRIBUTE5;
        l_avlv_rec_in.ATTRIBUTE6                    := avl_rec.ATTRIBUTE6;
        l_avlv_rec_in.ATTRIBUTE7                    := avl_rec.ATTRIBUTE7;
        l_avlv_rec_in.ATTRIBUTE8                    := avl_rec.ATTRIBUTE8;
        l_avlv_rec_in.ATTRIBUTE9                    := avl_rec.ATTRIBUTE9;
        l_avlv_rec_in.ATTRIBUTE10                   := avl_rec.ATTRIBUTE10;
        l_avlv_rec_in.ATTRIBUTE11                   := avl_rec.ATTRIBUTE11;
        l_avlv_rec_in.ATTRIBUTE12                   := avl_rec.ATTRIBUTE12;
        l_avlv_rec_in.ATTRIBUTE13                   := avl_rec.ATTRIBUTE13;
        l_avlv_rec_in.ATTRIBUTE14                   := avl_rec.ATTRIBUTE14;
        l_avlv_rec_in.ATTRIBUTE15                   := avl_rec.ATTRIBUTE15;

        l_avlv_rec_in.AES_ID                        := p_aes_id_to;
		l_avlv_rec_in.NAME                          := avl_rec.NAME || ' - COPY';

		OKL_TMPT_SET_PUB.create_template(p_api_version    => l_api_version
                                        ,p_init_msg_list  => l_init_msg_list
                                        ,x_return_status  => l_return_status
                                        ,x_msg_count      => l_msg_count
                                        ,x_msg_data       => l_msg_data
                                        ,p_avlv_rec       => l_avlv_rec_in
                                        ,x_avlv_rec       => l_avlv_rec_out);

        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

		-- Initialize the Variables

		    i := 0;
		    l_atlv_tbl_in.DELETE;

		    FOR atl_rec IN atl_csr(avl_rec.ID)

  		    LOOP

		       i := i + 1;

   		       l_atlv_tbl_in(i).SEQUENCE_NUMBER       := atl_rec.sequence_number;
               l_atlv_tbl_in(i).AVL_ID                := l_avlv_rec_out.ID;
               l_atlv_tbl_in(i).CODE_COMBINATION_ID   := atl_rec.code_combination_id;
               l_atlv_tbl_in(i).AE_LINE_TYPE          := atl_rec.ae_line_type;
               l_atlv_tbl_in(i).CRD_CODE              := atl_rec.crd_code;
               l_atlv_tbl_in(i).ACCOUNT_BUILDER_YN    := atl_rec.account_builder_yn;
               l_atlv_tbl_in(i).DESCRIPTION           := atl_rec.description;
               l_atlv_tbl_in(i).PERCENTAGE            := atl_rec.percentage;
               l_atlv_tbl_in(i).ATTRIBUTE_CATEGORY    := atl_rec.attribute_category;
               l_atlv_tbl_in(i).ATTRIBUTE1            := atl_rec.attribute1;
               l_atlv_tbl_in(i).ATTRIBUTE2            := atl_rec.attribute2;
               l_atlv_tbl_in(i).ATTRIBUTE3            := atl_rec.attribute3;
               l_atlv_tbl_in(i).ATTRIBUTE4            := atl_rec.attribute4;
               l_atlv_tbl_in(i).ATTRIBUTE5            := atl_rec.attribute5;
               l_atlv_tbl_in(i).ATTRIBUTE6            := atl_rec.attribute6;
               l_atlv_tbl_in(i).ATTRIBUTE7            := atl_rec.attribute7;
               l_atlv_tbl_in(i).ATTRIBUTE8            := atl_rec.attribute8;
               l_atlv_tbl_in(i).ATTRIBUTE9            := atl_rec.attribute9;
               l_atlv_tbl_in(i).ATTRIBUTE10           := atl_rec.attribute10;
               l_atlv_tbl_in(i).ATTRIBUTE11           := atl_rec.attribute11;
               l_atlv_tbl_in(i).ATTRIBUTE12           := atl_rec.attribute12;
               l_atlv_tbl_in(i).ATTRIBUTE13           := atl_rec.attribute13;
               l_atlv_tbl_in(i).ATTRIBUTE14           := atl_rec.attribute14;
               l_atlv_tbl_in(i).ATTRIBUTE15           := atl_rec.attribute15;


		    END LOOP;

  	        OKL_TMPT_SET_PUB.create_tmpt_lines(p_api_version    => l_api_version
                                              ,p_init_msg_list  => l_init_msg_list
                                              ,x_return_status  => l_return_status
                                              ,x_msg_count      => l_msg_count
                                              ,x_msg_data       => l_msg_data
                                              ,p_atlv_tbl       => l_atlv_tbl_in
                                              ,x_atlv_tbl       => l_atlv_tbl_out);


        END IF;


		IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

	           IF (l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN

		           l_overall_status := l_return_status;

  	           END IF;

  	    END IF;


   END LOOP;

   x_return_status := l_overall_status;


   EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN

           x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                       ,g_pkg_name
                                                       ,'OKL_API.G_RET_STS_ERROR'
                                                       ,x_msg_count
                                                       ,x_msg_data
                                                       ,'_PVT');

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

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

END COPY_TEMPLATES;


END OKL_COPY_TEMPLATE_PVT;

/
