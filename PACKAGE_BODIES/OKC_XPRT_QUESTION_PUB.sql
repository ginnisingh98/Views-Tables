--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_QUESTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_QUESTION_PUB" 
/* $Header: OKCPXIQB.pls 120.0.12010000.2 2011/03/10 18:05:31 harchand noship $ */
AS

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200)   := OKC_API.G_FND_APP;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200)   := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200)   := OKC_API.G_COL_NAME_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_QUESTION_PUB';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';

PROCEDURE create_question( p_xprt_question_rec  IN OUT  NOCOPY okc_xprt_question_pvt.xprt_qn_const_rec_type
                          ,p_commit              IN              VARCHAR2 := fnd_api.g_false
                         )
IS

x_return_status varchar2(1);
x_msg_data    varchar2(2500);

BEGIN

     p_xprt_question_rec.QN_CONST_type := 'Q';

     OKC_XPRT_QUESTION_PVT.create_question
                          (p_xprt_question_rec            => p_xprt_question_rec,
                           p_commit                       => p_commit,
                           x_return_status                => x_return_status,
                           x_msg_data                     => x_msg_data
                          );

                          p_xprt_question_rec.sts := x_return_status;
                          p_xprt_question_rec.MSG := x_msg_data;

EXCEPTION
WHEN OTHERS THEN
 RAISE;
END create_question;

PROCEDURE create_question( p_xprt_question_tbl  IN OUT  NOCOPY okc_xprt_question_pvt.xprt_qn_const_tbl_type
                          ,p_commit              IN              VARCHAR2 := fnd_api.g_false)
IS
l_count NUMBER;
BEGIN
   l_count:=p_xprt_question_tbl.Count;

   FOR i IN p_xprt_question_tbl.first ..p_xprt_question_tbl.last
   LOOP
      BEGIN
      create_question(p_xprt_question_rec => p_xprt_question_tbl(i), p_commit => p_commit);
      EXCEPTION
        WHEN OTHERS THEN
         p_xprt_question_tbl(i).sts:= G_RET_STS_UNEXP_ERROR;
         p_xprt_question_tbl(i).MSG:=SQLERRM;
      END;
   END LOOP;

EXCEPTION
WHEN OTHERS THEN
 RAISE;
END create_question;



PROCEDURE update_question(p_xprt_update_question_rec  IN OUT  NOCOPY okc_xprt_question_pvt.xprt_qn_const_rec_type
                          ,p_commit              IN              VARCHAR2 := fnd_api.g_false)
IS


x_return_status varchar2(1);
x_msg_data    varchar2(2500);


BEGIN

 p_xprt_update_question_rec.QN_CONST_type := 'Q';

 OKC_XPRT_QUESTION_PVT.update_question
                          (p_xprt_update_question_rec  => p_xprt_update_question_rec,
                           p_commit             => p_commit,
                           x_return_status      => x_return_status,
                           x_msg_data           => x_msg_data
                          );
                          p_xprt_update_question_rec.sts := x_return_status;
                          p_xprt_update_question_rec.MSG := x_msg_data;
EXCEPTION
WHEN OTHERS THEN
 RAISE;
END update_question;




PROCEDURE update_question(p_xprt_update_question_tbl  IN OUT  NOCOPY okc_xprt_question_pvt.xprt_qn_const_tbl_type
                          ,p_commit              IN              VARCHAR2 := fnd_api.g_false)
IS
l_count NUMBER;
BEGIN
   l_count:=p_xprt_update_question_tbl.Count;
   FOR i IN p_xprt_update_question_tbl.first ..p_xprt_update_question_tbl.last
   LOOP
      BEGIN
      update_question (p_xprt_update_question_rec => p_xprt_update_question_tbl(i)
                      ,p_commit             => p_commit);
      EXCEPTION
        WHEN OTHERS THEN
         p_xprt_update_question_tbl(i).sts := G_RET_STS_UNEXP_ERROR;
         p_xprt_update_question_tbl(i).MSG := SQLERRM;
      END;
   END LOOP;
EXCEPTION
WHEN OTHERS THEN
 RAISE;
END update_question;


PROCEDURE create_constant( p_xprt_constant_rec  IN OUT  NOCOPY okc_xprt_question_pvt.xprt_qn_const_rec_type
                          ,p_commit              IN              VARCHAR2 := fnd_api.g_false
                         )
IS

x_return_status varchar2(1);
x_msg_data    varchar2(2500);

BEGIN
     p_xprt_constant_rec.QN_CONST_type := 'C';

     OKC_XPRT_QUESTION_PVT.create_question
                          (p_xprt_question_rec            => p_xprt_constant_rec,
                           p_commit                       => p_commit,
                           x_return_status                => x_return_status,
                           x_msg_data                     => x_msg_data
                          );

                          p_xprt_constant_rec.sts := x_return_status;
                          p_xprt_constant_rec.MSG := x_msg_data;

EXCEPTION
WHEN OTHERS THEN
 RAISE;
END create_constant;

PROCEDURE create_constant( p_xprt_constant_tbl  IN OUT  NOCOPY okc_xprt_question_pvt.xprt_qn_const_tbl_type
                          ,p_commit              IN              VARCHAR2 := fnd_api.g_false)
IS
l_count NUMBER;
BEGIN
   l_count:=p_xprt_constant_tbl.Count;

   FOR i IN p_xprt_constant_tbl.first ..p_xprt_constant_tbl.last
   LOOP
      BEGIN
      create_constant(p_xprt_constant_rec => p_xprt_constant_tbl(i), p_commit => p_commit);
      EXCEPTION
        WHEN OTHERS THEN
         p_xprt_constant_tbl(i).sts:= G_RET_STS_UNEXP_ERROR;
         p_xprt_constant_tbl(i).MSG:=SQLERRM;
      END;
   END LOOP;

EXCEPTION
WHEN OTHERS THEN
 RAISE;
END create_constant;



PROCEDURE update_constant(p_xprt_update_constant_rec  IN OUT  NOCOPY okc_xprt_question_pvt.xprt_qn_const_rec_type
                          ,p_commit              IN              VARCHAR2 := fnd_api.g_false)
IS


x_return_status varchar2(1);
x_msg_data    varchar2(2500);


BEGIN

 p_xprt_update_constant_rec.QN_CONST_type := 'C';
 OKC_XPRT_QUESTION_PVT.update_question
                          (p_xprt_update_question_rec  => p_xprt_update_constant_rec,
                           p_commit             => p_commit,
                           x_return_status      => x_return_status,
                           x_msg_data           => x_msg_data
                          );
                          p_xprt_update_constant_rec.sts := x_return_status;
                          p_xprt_update_constant_rec.MSG := x_msg_data;
EXCEPTION
WHEN OTHERS THEN
 RAISE;
END update_constant;




PROCEDURE update_constant(p_xprt_update_constant_tbl  IN OUT  NOCOPY okc_xprt_question_pvt.xprt_qn_const_tbl_type
                          ,p_commit              IN              VARCHAR2 := fnd_api.g_false)
IS
l_count NUMBER;
BEGIN
   l_count:=p_xprt_update_constant_tbl.Count;
   FOR i IN p_xprt_update_constant_tbl.first ..p_xprt_update_constant_tbl.last
   LOOP
      BEGIN
      update_constant (p_xprt_update_constant_rec => p_xprt_update_constant_tbl(i)
                      ,p_commit             => p_commit);
      EXCEPTION
        WHEN OTHERS THEN
         p_xprt_update_constant_tbl(i).sts := G_RET_STS_UNEXP_ERROR;
         p_xprt_update_constant_tbl(i).MSG := SQLERRM;
      END;
   END LOOP;
EXCEPTION
WHEN OTHERS THEN
 RAISE;
END update_constant;

END OKC_XPRT_QUESTION_PUB;

/
