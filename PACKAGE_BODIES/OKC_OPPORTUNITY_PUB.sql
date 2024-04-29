--------------------------------------------------------
--  DDL for Package Body OKC_OPPORTUNITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OPPORTUNITY_PUB" AS
/* $Header: OKCPOPPB.pls 120.0 2005/05/26 09:54:21 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  /*****************
  PROCEDURE CREATE_OPPORTUNITY(p_context             IN  VARCHAR2,
                               p_contract_id         IN  NUMBER,
                               p_win_probability     IN  NUMBER,
                               p_expected_close_days IN  NUMBER,
                               x_lead_id             OUT NOCOPY NUMBER,
                               x_return_status       OUT NOCOPY VARCHAR2) IS
  *******************/
  PROCEDURE CREATE_OPPORTUNITY(p_api_version         IN NUMBER ,
                               p_commit              IN VARCHAR2 ,
                               p_context             IN  VARCHAR2,
                               p_contract_id         IN  NUMBER,
                               p_win_probability     IN  NUMBER,
                               p_expected_close_days IN  NUMBER,
                               x_lead_id             OUT NOCOPY NUMBER,
                               p_init_msg_list       IN VARCHAR2,
                               x_msg_data            OUT NOCOPY VARCHAR2,
                               x_msg_count           OUT NOCOPY NUMBER,
                               x_return_status       OUT NOCOPY VARCHAR2) IS

  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Create_Opportunity');
       okc_debug.log('100: Entering okc_opportunity_pub.create_opportunity', 2);
    END IF;
    okc_opportunity_pvt.Create_Opportunity(p_api_version,
                                           p_context,
                                           p_contract_id,
                                           p_win_probability,
                                           p_expected_close_days,
                                           x_lead_id,
                                           p_init_msg_list,
                                           x_msg_data,
                                           x_msg_count,
                                           x_return_status);

    IF x_return_status = OKC_API.G_RET_STS_SUCCESS AND p_commit = OKC_API.G_TRUE THEN
       commit;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Exiting okc_opportunity_pub.create_opportunity', 2);
       okc_debug.Reset_Indentation;
    END IF;
  End;

  PROCEDURE CREATE_OPPORTUNITY(p_api_version         IN NUMBER ,
                               p_commit              IN VARCHAR2 ,
                               p_context             IN  VARCHAR2,
                               p_contract_id         IN  NUMBER,
                               p_win_probability     IN  NUMBER,
                               p_expected_close_days IN  NUMBER,
                               -------x_lead_id             OUT NOCOPY NUMBER,
                               p_init_msg_list       IN VARCHAR2,
                               x_msg_data            OUT NOCOPY VARCHAR2,
                               x_msg_count           OUT NOCOPY NUMBER,
                               x_return_status       OUT NOCOPY VARCHAR2) IS

  l_lead_id   NUMBER;
  Begin
    Create_Opportunity(p_api_version,
                      p_commit,
                      p_context,
                      p_contract_id,
                      p_win_probability,
                      p_expected_close_days,
                      l_lead_id,
                      p_init_msg_list,
                      x_msg_data,
                      x_msg_count,
                      x_return_status);
  End;


  /****************
  PROCEDURE CREATE_OPP_HEADER(p_context             IN  VARCHAR2,
                              p_contract_id         IN  NUMBER,
                              p_win_probability     IN  NUMBER,
                              p_expected_close_days IN  NUMBER,
                              x_lead_id             OUT NOCOPY NUMBER,
                              x_return_status       OUT NOCOPY VARCHAR2) IS
  *******************/
 PROCEDURE CREATE_OPP_HEADER(p_api_version         IN NUMBER ,
                              p_context             IN  VARCHAR2,
                              p_contract_id         IN  NUMBER,
                              p_win_probability     IN  NUMBER,
                              p_expected_close_days IN  NUMBER,
                              x_lead_id             OUT NOCOPY NUMBER,
                              p_init_msg_list       IN VARCHAR2,
                              x_msg_data            OUT NOCOPY VARCHAR2,
                              x_msg_count           OUT NOCOPY NUMBER,
                              x_return_status       OUT NOCOPY VARCHAR2) IS

  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Create_Opp_Header');
       okc_debug.log('300: Entering okc_opportunity_pub.create_opp_header', 2);
    END IF;
    okc_opportunity_pvt.Create_Opp_Header(p_api_version,
                                          p_context,
                                          p_contract_id,
                                          p_win_probability,
                                          p_expected_close_days,
                                          x_lead_id,
                                          p_init_msg_list,
                                          x_msg_data,
                                          x_msg_count,
                                          x_return_status);
    IF (l_debug = 'Y') THEN
       okc_debug.log('400: Exiting okc_opportunity_pub.create_opp_header', 2);
       okc_debug.Reset_Indentation;
    END IF;
  End;

  /****************
  PROCEDURE CREATE_OPP_LINES(p_context       IN  VARCHAR2,
                             p_contract_id   IN  NUMBER,
                             p_lead_id       IN  NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2) IS
  ******************/
  PROCEDURE CREATE_OPP_LINES(p_api_version         IN NUMBER ,
                             p_context       IN  VARCHAR2,
                             p_contract_id   IN  NUMBER,
                             p_lead_id       IN  NUMBER,
                             p_init_msg_list IN VARCHAR2,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2) IS

  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Create_Opp_Lines');
       okc_debug.log('500: Entering okc_opportunity_pub.create_opp_lines', 2);
    END IF;
    okc_opportunity_pvt.create_opp_lines(p_api_version,
                                         p_context,
                                         p_contract_id,
                                         p_lead_id,
                                         p_init_msg_list,
                                         x_msg_data,
                                         x_msg_count,
                                         x_return_status);
    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting okc_opportunity_pub.create_opp_lines', 2);
       okc_debug.Reset_Indentation;
    END IF;
  End;

  PROCEDURE IS_OPP_CREATION_ALLOWED(p_context       IN  VARCHAR2,
                                    p_contract_id   IN  NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2) IS
  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Is_Opp_Creation_Allowed');
       okc_debug.log('700: Entering okc_opportunity_pub.is_opp_creation_allowed', 2);
    END IF;
    okc_opportunity_pvt.is_opp_creation_allowed(p_context,
                                                p_contract_id,
                                                x_return_status);
    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting okc_opportunity_pub.is_opp_creation_allowed', 2);
       okc_debug.Reset_Indentation;
    END IF;
  End;

  PROCEDURE GET_OPP_DEFAULTS(p_context           IN  VARCHAR2,
                             p_contract_id       IN  NUMBER,
                             x_win_probability   IN  OUT NOCOPY NUMBER,
                             x_closing_date_days IN  OUT NOCOPY NUMBER,
                             x_return_status     OUT NOCOPY VARCHAR2) IS
  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Get_Opp_Defaults');
       okc_debug.log('900: Entering okc_opportunity_pub.get_opp_defaults', 2);
    END IF;
    okc_opportunity_pvt.get_opp_defaults(p_context,
                                         p_contract_id,
                                         x_win_probability,
                                         x_closing_date_days,
                                         x_return_status);
    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Exiting okc_opportunity_pub.get_opp_defaults', 2);
       okc_debug.Reset_Indentation;
    END IF;
  End;
END OKC_OPPORTUNITY_PUB;

/
