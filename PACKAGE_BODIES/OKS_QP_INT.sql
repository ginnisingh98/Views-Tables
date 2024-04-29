--------------------------------------------------------
--  DDL for Package Body OKS_QP_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_QP_INT" AS
/* $Header: OKSGPINB.pls 120.0 2005/05/25 18:27:58 appldev noship $ */

   l_api_version   CONSTANT NUMBER      := 1.0;
   l_init_msg_list CONSTANT VARCHAR2(1) := 'F';

   PROCEDURE GET_CONVERSION_FACTOR (
                 p_api_version       IN         NUMBER,
                 p_init_msg_list     IN         VARCHAR2,
                 p_start_date        IN         DATE,
                 p_end_date          IN         DATE,
                 p_pb_uom            IN         VARCHAR2,
                 x_factor            OUT NOCOPY NUMBER,
                 x_return_status     OUT NOCOPY VARCHAR2,
                 x_msg_count         OUT NOCOPY NUMBER,
                 x_msg_data          OUT NOCOPY VARCHAR2
       ) IS

       l_duration          NUMBER;
       l_uom               VARCHAR2(10);

   BEGIN

       x_return_status := G_RET_STS_SUCCESS;

       OKS_TIME_MEASURES_PUB.get_duration_uom (
                               p_start_date    => p_start_date
                             , p_end_date      => p_end_date
                             , x_duration      => l_duration
                             , x_timeunit      => l_uom
                             , x_return_status => x_return_status
                         );

       IF x_return_status <> G_RET_STS_SUCCESS THEN
          x_factor := NULL;
          RAISE G_EXC_ERROR;
       END IF;

       IF UPPER(p_pb_uom) = UPPER(l_uom) THEN
          IF l_duration = 1 THEN
             x_factor := 1;
          ELSE
             x_factor := l_duration;
          END IF;
       ELSE
          x_factor := OKS_TIME_MEASURES_PUB.get_target_qty (
                                              p_start_date  => p_start_date,
                                              p_source_qty  => l_duration,
                                              p_source_uom  => l_uom,
                                              p_target_uom  => p_pb_uom,
                                              p_round_dec   => 20
                                           );
       END IF;
   EXCEPTION
       WHEN G_EXC_ERROR THEN
            NULL;
       WHEN OTHERS THEN
            x_return_status := G_RET_STS_UNEXP_ERROR;
            OKC_API.SET_MESSAGE(
                       p_app_name     => G_APP_NAME,
                       p_msg_name     => G_UNEXPECTED_ERROR,
                       p_token1       => G_SQLCODE_TOKEN,
                       p_token1_value => SQLCODE,
                       p_token2       => G_SQLERRM_TOKEN,
                       p_token2_value => SQLERRM
                   );
   END GET_CONVERSION_FACTOR;

END OKS_QP_INT;

/
