--------------------------------------------------------
--  DDL for Package Body OKC_PRICE_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PRICE_ADJUSTMENT_PVT" AS
/* $Header: OKCCPATB.pls 120.0 2005/05/25 19:11:45 appldev noship $*/

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Complex API for Price Adjusments

 PROCEDURE create_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type,
    x_patv_rec                     OUT NOCOPY patv_rec_type) IS
 BEGIN

 okc_pat_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_patv_rec,
	    x_patv_rec);

 END create_price_adjustment;

 PROCEDURE create_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type,
    x_patv_tbl                     OUT NOCOPY patv_tbl_type) IS
 BEGIN
 okc_pat_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_patv_tbl,
	    x_patv_tbl);

 END create_price_adjustment;


 PROCEDURE update_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type,
    x_patv_rec                     OUT NOCOPY patv_rec_type) IS
 BEGIN

 okc_pat_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_patv_rec,
	    x_patv_rec);

 END update_price_adjustment;

 PROCEDURE update_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type,
    x_patv_tbl                     OUT NOCOPY patv_tbl_type)IS
 BEGIN

 okc_pat_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_patv_tbl,
	    x_patv_tbl);

 END update_price_adjustment;
---****************************************************************************************
PROCEDURE delete_price_adjustment(
    p_api_version                 IN NUMBER,
    p_init_msg_list               IN VARCHAR2 ,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,
    p_patv_rec                    IN patv_rec_type) IS

    l_patv_rec  okc_price_adjustment_PUB.patv_rec_type;  --for price adjustments
    l_pacv_rec  okc_price_adjustment_PUB.pacv_rec_type;  --for price adjustment assoc
    l_pavv_rec  okc_price_adjustment_PUB.paav_rec_type;  --for price adjustment attributes

--cursor to fetch the child lines
  CURSOR l_padj_csr IS
    SELECT A.id,A.chr_id,A.cle_id
    FROM OKC_PRICE_ADJUSTMENTS_V A,
         OKC_PRICE_ADJ_ASSOCS_V  B
    WHERE B.pat_id_from = p_patv_rec.id
    AND   A.ID          = B.PAT_ID
    AND  (A.chr_id    = p_patv_rec.chr_id
        OR  A.cle_id    = p_patv_rec.cle_id);
--
  CURSOR l_assoc_csr IS
    SELECT id
    FROM OKC_PRICE_ADJ_ASSOCS_V
    WHERE  pat_id_from = p_patv_rec.id;
--

  CURSOR l_attrib_csr IS
    SELECT id
    FROM OKC_PRICE_ADJ_ATTRIBS_V
    WHERE  pat_id = p_patv_rec.id;
--

 BEGIN

-- delete parent record from OKC_PRICE_ADJUSTMENTS.
   okc_pat_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_patv_rec );

    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

        For padj_rec In l_padj_csr   Loop
            l_patv_rec.id := padj_rec.id;
            l_patv_rec.chr_id := padj_rec.chr_id;
            l_patv_rec.cle_id := padj_rec.cle_id;

              -- Delete all child records  from OKC__PRICE_ADJUSTMENTS.
              OKC_PRICE_ADJUSTMENT_PUB.delete_price_adjustment(
                                    p_api_version  => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count    => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_patv_rec      => l_patv_rec);

                IF (X_return_status <> 'S') Then
                    EXIT;
                END IF;
          END LOOP;
    End If;

    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        For assoc_rec In l_assoc_csr Loop
              l_pacv_rec.id := assoc_rec.id;

              -- Delete related records from OKC_PRICE_ADJ_ASSOCS_V
              OKC_PRICE_ADJUSTMENT_PUB.delete_price_adj_assoc(
                                p_api_version  => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count    => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_pacv_rec      => l_pacv_rec );
              IF (X_return_status <> 'S') Then
                  EXIT;
              END IF;
          END LOOP;
    End if;

    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

        For attrib_rec In l_attrib_csr Loop
              l_pavv_rec.id := attrib_rec.id;

              --Delete related records in OKC_PRICE_ADJ_ATTRIBS_V
              OKC_PRICE_ADJUSTMENT_PUB.delete_price_adj_attrib(
                        p_api_version  => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count    => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_paav_rec      => l_pavv_rec);
              IF (X_return_status <> 'S') Then
                  EXIT;
              END IF;
          END LOOP;
    END IF;
END delete_price_adjustment;
---
 PROCEDURE delete_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type)IS
 BEGIN

   okc_pat_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_patv_tbl);

 END delete_price_adjustment;

 PROCEDURE validate_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type)IS
 BEGIN

 okc_pat_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_patv_rec);

 END validate_price_adjustment;

 PROCEDURE validate_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type)IS
 BEGIN

 okc_pat_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_patv_tbl);

 END validate_price_adjustment;

 PROCEDURE lock_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type)IS

 BEGIN

 okc_pat_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_patv_rec);

 END lock_price_adjustment;

 PROCEDURE lock_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type)IS

 BEGIN

 okc_pat_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_patv_tbl);

 END lock_price_adjustment;



 PROCEDURE create_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type,
    x_pacv_rec                     OUT NOCOPY pacv_rec_type) IS
 BEGIN

 okc_pac_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pacv_rec,
	    x_pacv_rec);

 END create_price_adj_assoc;

 PROCEDURE create_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type,
    x_pacv_tbl                     OUT NOCOPY pacv_tbl_type) IS
 BEGIN
 okc_pac_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pacv_tbl,
	    x_pacv_tbl);

 END create_price_adj_assoc;


 PROCEDURE update_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type,
    x_pacv_rec                     OUT NOCOPY pacv_rec_type) IS
 BEGIN

 okc_pac_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pacv_rec,
	    x_pacv_rec);

 END update_price_adj_assoc;

 PROCEDURE update_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type,
    x_pacv_tbl                     OUT NOCOPY pacv_tbl_type)IS
 BEGIN

 okc_pac_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pacv_tbl,
	    x_pacv_tbl);

 END update_price_adj_assoc;


 PROCEDURE delete_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type)IS
 BEGIN

 okc_pac_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pacv_rec );

 END delete_price_adj_assoc;

 PROCEDURE delete_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type)IS
 BEGIN

   okc_pac_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pacv_tbl);

 END delete_price_adj_assoc;

 PROCEDURE validate_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type)IS
 BEGIN

 okc_pac_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pacv_rec);

 END validate_price_adj_assoc;

 PROCEDURE validate_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type)IS
 BEGIN

 okc_pac_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pacv_tbl);

 END validate_price_adj_assoc;

 PROCEDURE lock_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type)IS

 BEGIN

 okc_pac_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pacv_rec);

 END lock_price_adj_assoc;

 PROCEDURE lock_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type)IS

 BEGIN

 okc_pac_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pacv_tbl);

 END lock_price_adj_assoc;

 PROCEDURE create_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type,
    x_paav_rec                     OUT NOCOPY paav_rec_type) IS
 BEGIN

 okc_paa_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_paav_rec,
	    x_paav_rec);

 END create_price_adj_attrib;

 PROCEDURE create_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type,
    x_paav_tbl                     OUT NOCOPY paav_tbl_type) IS
 BEGIN
 okc_paa_pvt.insert_row(
	    p_api_version ,
            p_init_msg_list ,
            x_return_status ,
            x_msg_count ,
            x_msg_data ,
            p_paav_tbl ,
            x_paav_tbl );


 END create_price_adj_attrib;


 PROCEDURE update_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type,
    x_paav_rec                     OUT NOCOPY paav_rec_type) IS
 BEGIN

 okc_paa_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_paav_rec,
	    x_paav_rec);

 END update_price_adj_attrib;

 PROCEDURE update_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type,
    x_paav_tbl                     OUT NOCOPY paav_tbl_type)IS
 BEGIN

 okc_paa_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_paav_tbl,
	    x_paav_tbl);

 END update_price_adj_attrib;


 PROCEDURE delete_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type)IS
 BEGIN

 okc_paa_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_paav_rec );

 END delete_price_adj_attrib;

 PROCEDURE delete_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type)IS
 BEGIN

   okc_paa_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_paav_tbl);

 END delete_price_adj_attrib;

 PROCEDURE validate_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type)IS
 BEGIN

 okc_paa_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_paav_rec);

 END validate_price_adj_attrib;

 PROCEDURE validate_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type)IS
 BEGIN

 okc_paa_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_paav_tbl);

 END validate_price_adj_attrib;

 PROCEDURE lock_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type)IS

 BEGIN

 okc_paa_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_paav_rec);

 END lock_price_adj_attrib;

 PROCEDURE lock_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type)IS

 BEGIN

 okc_paa_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_paav_tbl);

 END lock_price_adj_attrib;

 PROCEDURE create_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type,
    x_pavv_rec                     OUT NOCOPY pavv_rec_type) IS
 BEGIN

 okc_pav_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pavv_rec,
	    x_pavv_rec);

 END create_price_att_value;

 PROCEDURE create_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type,
    x_pavv_tbl                     OUT NOCOPY pavv_tbl_type) IS
 BEGIN
 okc_pav_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pavv_tbl,
	    x_pavv_tbl);

 END create_price_att_value;


 PROCEDURE update_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type,
    x_pavv_rec                     OUT NOCOPY pavv_rec_type) IS
 BEGIN

 okc_pav_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pavv_rec,
	    x_pavv_rec);

 END update_price_att_value;

 PROCEDURE update_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type,
    x_pavv_tbl                     OUT NOCOPY pavv_tbl_type)IS
 BEGIN

 okc_pav_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pavv_tbl,
	    x_pavv_tbl);

 END update_price_att_value;


 PROCEDURE delete_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type)IS
 BEGIN

 okc_pav_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pavv_rec );

 END delete_price_att_value;

 PROCEDURE delete_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type)IS
 BEGIN

   okc_pav_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pavv_tbl);

 END delete_price_att_value;

 PROCEDURE validate_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type)IS
 BEGIN

 okc_pav_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pavv_rec);

 END validate_price_att_value;

 PROCEDURE validate_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type)IS
 BEGIN

 okc_pav_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pavv_tbl);

 END validate_price_att_value;

 PROCEDURE lock_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type)IS

 BEGIN

 okc_pav_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pavv_rec);

 END lock_price_att_value;

 PROCEDURE lock_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type)IS

 BEGIN

 okc_pav_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pavv_tbl);

 END lock_price_att_value;

END okc_price_adjustment_pvt;

/
