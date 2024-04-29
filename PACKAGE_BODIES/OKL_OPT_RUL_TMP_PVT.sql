--------------------------------------------------------
--  DDL for Package Body OKL_OPT_RUL_TMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPT_RUL_TMP_PVT" AS
/* $Header: OKLRRTMB.pls 115.1 2002/02/25 17:08:24 pkm ship        $ */

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovd_id					   IN NUMBER,
    p_rgrv_rec                     IN rgrv_rec_type,
    x_rgrv_rec                     OUT NOCOPY rgrv_rec_type)
  IS

    l_return_status   			   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
	l_ovtv_rec		  			   ovtv_rec_type;
	x_ovtv_rec					   ovtv_rec_type;

	--PK of OVD to retrieve context:
	-- 	Passed as IN information to get context info
	l_ovd_id					   NUMBER;

	l_rgd_code					   okl_opt_rules.RGR_RGD_CODE%TYPE;
	l_rdf_code					   okl_opt_rules.RGR_RDF_CODE%TYPE;

	--Local definition of an OKC_RULES_B record which actually is passsed to the
	--RUL TAPI. It copies fields from the incoming record.
	l_rulv_rec		  			   rulv_rec_type;
	x_rulv_rec		  			   rulv_rec_type;

	CURSOR context_info (p_in_id NUMBER) IS
		   SELECT rgr_rgd_code,
	   	   		  rgr_rdf_code
		   FROM  OKL_OPT_RULES	ORL,
	  	   		 OKL_OPV_RULES	OVD
		   WHERE OVD.ORL_ID = ORL.ID
		   AND 	 OVD.ID = p_in_id;

	l_msg_count NUMBER ;
	l_msg_data VARCHAR2(2000);

  BEGIN
  SAVEPOINT Opt_Rul_Tmp_insert;

  l_ovd_id := p_ovd_id;

   OPEN  context_info(l_ovd_id);
   FETCH context_info INTO l_rgd_code, l_rdf_code;
   CLOSE context_info;

   l_rulv_rec.OBJECT1_ID1                   := p_rgrv_rec.OBJECT1_ID1;
   l_rulv_rec.OBJECT2_ID1                   := p_rgrv_rec.OBJECT2_ID1;
   l_rulv_rec.OBJECT3_ID1                   := p_rgrv_rec.OBJECT3_ID1;
   l_rulv_rec.OBJECT1_ID2                   := p_rgrv_rec.OBJECT1_ID2;
   l_rulv_rec.OBJECT2_ID2                   := p_rgrv_rec.OBJECT2_ID2;
   l_rulv_rec.OBJECT3_ID2                   := p_rgrv_rec.OBJECT3_ID2;
   l_rulv_rec.JTOT_OBJECT1_CODE             := p_rgrv_rec.JTOT_OBJECT1_CODE;
   l_rulv_rec.JTOT_OBJECT2_CODE             := p_rgrv_rec.JTOT_OBJECT2_CODE;
   l_rulv_rec.JTOT_OBJECT3_CODE             := p_rgrv_rec.JTOT_OBJECT3_CODE;
   l_rulv_rec.PRIORITY                      := NULL;
   l_rulv_rec.STD_TEMPLATE_YN               := 'Y';
   l_rulv_rec.COMMENTS                      := p_rgrv_rec.COMMENTS;
   l_rulv_rec.WARN_YN                       := 'Y';
   l_rulv_rec.ATTRIBUTE_CATEGORY            := NULL;
   l_rulv_rec.ATTRIBUTE1                    := NULL;
   l_rulv_rec.ATTRIBUTE2                    := NULL;
   l_rulv_rec.ATTRIBUTE3                    := NULL;
   l_rulv_rec.ATTRIBUTE4                    := NULL;
   l_rulv_rec.ATTRIBUTE5                    := NULL;
   l_rulv_rec.ATTRIBUTE6                    := NULL;
   l_rulv_rec.ATTRIBUTE7                    := NULL;
   l_rulv_rec.ATTRIBUTE8                    := NULL;
   l_rulv_rec.ATTRIBUTE9                    := NULL;
   l_rulv_rec.ATTRIBUTE10                   := NULL;
   l_rulv_rec.ATTRIBUTE11                   := NULL;
   l_rulv_rec.ATTRIBUTE12                   := NULL;
   l_rulv_rec.ATTRIBUTE13                   := NULL;
   l_rulv_rec.ATTRIBUTE14                   := NULL;
   l_rulv_rec.RULE_INFORMATION_CATEGORY     := p_rgrv_rec.RULE_INFORMATION_CATEGORY;
   l_rulv_rec.RULE_INFORMATION1             := p_rgrv_rec.RULE_INFORMATION1;
   l_rulv_rec.RULE_INFORMATION2             := p_rgrv_rec.RULE_INFORMATION2;
   l_rulv_rec.RULE_INFORMATION3             := p_rgrv_rec.RULE_INFORMATION3;
   l_rulv_rec.RULE_INFORMATION4             := p_rgrv_rec.RULE_INFORMATION4;
   l_rulv_rec.RULE_INFORMATION5             := p_rgrv_rec.RULE_INFORMATION5;
   l_rulv_rec.RULE_INFORMATION6             := p_rgrv_rec.RULE_INFORMATION6;
   l_rulv_rec.RULE_INFORMATION7             := p_rgrv_rec.RULE_INFORMATION7;
   l_rulv_rec.RULE_INFORMATION8             := p_rgrv_rec.RULE_INFORMATION8;
   l_rulv_rec.RULE_INFORMATION9             := p_rgrv_rec.RULE_INFORMATION9;
   l_rulv_rec.RULE_INFORMATION10            := p_rgrv_rec.RULE_INFORMATION10;
   l_rulv_rec.RULE_INFORMATION11            := p_rgrv_rec.RULE_INFORMATION11;
   l_rulv_rec.RULE_INFORMATION12            := p_rgrv_rec.RULE_INFORMATION12;
   l_rulv_rec.RULE_INFORMATION13            := p_rgrv_rec.RULE_INFORMATION13;
   l_rulv_rec.RULE_INFORMATION14            := p_rgrv_rec.RULE_INFORMATION14;
   l_rulv_rec.RULE_INFORMATION15            := p_rgrv_rec.RULE_INFORMATION15;
   l_rulv_rec.TEMPLATE_YN                   := 'Y';
   l_rulv_rec.ANS_SET_JTOT_OBJECT_CODE      := NULL;
   l_rulv_rec.ANS_SET_JTOT_OBJECT_ID1       := NULL;
   l_rulv_rec.ANS_SET_JTOT_OBJECT_ID2       := NULL;
   l_rulv_rec.DISPLAY_SEQUENCE              := NULL;


    Okc_Rul_Pvt.INSERT_ROW(
    					   p_api_version,
    					   p_init_msg_list,
    					   x_return_status,
    					   x_msg_count,
    					   x_msg_data,
    					   l_rulv_rec,
    					   x_rulv_rec);

    -- Populate mandatory fields for the creation of in
    l_ovtv_rec.ovd_id 	   			  := l_ovd_id;
	l_ovtv_rec.RUL_ID     			  := x_rulv_rec.id;
	l_ovtv_rec.SEQUENCE_NUMBER        := 1;
  	--Create Intersection Record between Option Values and Rule Template
    Okl_Ovd_Rul_Tmls_Pub.insert_ovd_rul_tmls(p_api_version   => p_api_version,
                              		         p_init_msg_list => p_init_msg_list,
                              		 	   	 x_return_status => l_return_status,
                              		 	   	 x_msg_count     => x_msg_count,
                              		 	   	 x_msg_data      => x_msg_data,
                              		 	   	 p_ovtv_rec      => l_ovtv_rec,
                              		 	   	 x_ovtv_rec      => x_ovtv_rec);
  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_Opt_Rul_Tmp_PVT','insert_Opt_Rul_Tmp');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END insert_row;


  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovd_id					   IN NUMBER,
    p_rgrv_tbl                     IN rgrv_tbl_type,
    x_rgrv_tbl                     OUT NOCOPY rgrv_tbl_type)
  IS

  p_rgrv_rec						rgrv_rec_type;
  x_rgrv_rec						rgrv_rec_type;

  l_msg_count NUMBER ;
  l_msg_data VARCHAR2(2000);

  BEGIN
  	 SAVEPOINT Opt_Rul_Tmp_insert;

	 FOR i IN  p_rgrv_tbl.first..p_rgrv_tbl.COUNT LOOP

	 	 p_rgrv_rec := p_rgrv_tbl(i);

		   Okl_Opt_Rul_Tmp_Pvt.insert_row(
                          p_api_version
                         ,p_init_msg_list
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data
						 ,p_ovd_id
                         ,p_rgrv_rec
                         ,x_rgrv_rec);

	 END LOOP;
  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_Opt_Rul_Tmp_PVT','insert_Opt_Rul_Tmp');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END insert_row;


  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_rec                     IN rgrv_rec_type,
    x_rgrv_rec                     OUT NOCOPY rgrv_rec_type)
  IS
  BEGIN
  	   NULL;
  END update_row;


  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_tbl                     IN rgrv_tbl_type,
    x_rgrv_tbl                     OUT NOCOPY rgrv_tbl_type)
  IS
  BEGIN
  	   NULL;
  END update_row;


  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_rec                     IN rgrv_rec_type)
  IS
  BEGIN
  	   NULL;
  END delete_row;


PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_tbl                     IN rgrv_tbl_type)
  IS
  BEGIN
  	   NULL;
  END delete_row;


END Okl_Opt_Rul_Tmp_Pvt;

/
