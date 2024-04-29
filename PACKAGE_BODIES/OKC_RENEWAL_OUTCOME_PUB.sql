--------------------------------------------------------
--  DDL for Package Body OKC_RENEWAL_OUTCOME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RENEWAL_OUTCOME_PUB" AS
/* $Header: OKCPORWB.pls 120.0 2005/05/25 19:33:46 appldev noship $*/
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE Renewal_Outcome( p_api_version                IN NUMBER
                    ,p_init_msg_list              IN VARCHAR2
                    ,x_return_status              OUT NOCOPY VARCHAR2
                    ,x_msg_count                  OUT NOCOPY NUMBER
                    ,x_msg_data                   OUT NOCOPY VARCHAR2
                    --
                    -- ,x_contract_id                OUT NOCOPY number
                    --
                    ,p_contract_id                IN NUMBER
                    ,p_contract_number            IN VARCHAR2
                    ,p_contract_version           IN VARCHAR2
                    ,p_contract_modifier          IN VARCHAR2
                    ,p_object_version_number      IN NUMBER
                    ,p_new_contract_number        IN VARCHAR2
                    ,p_new_contract_modifier      IN VARCHAR2
                    ,p_start_date                 IN DATE
                    ,p_end_date                   IN DATE
                    ,p_orig_start_date            IN DATE
                    ,p_orig_end_date              IN DATE
                    ,p_uom_code                   IN VARCHAR2
                    ,p_duration                   IN NUMBER
                    ,p_context                    IN VARCHAR2
                    ,p_perpetual_flag             IN VARCHAR2
                    --
                    ,p_do_commit                  IN VARCHAR2) IS

    -- Variables
    l_api_name              CONSTANT VARCHAR2(30)    := 'Renewal Outcome';
    l_api_version           CONSTANT NUMBER          := 1.0;
    l_return_status                  VARCHAR2(1)     := OKC_API.G_RET_STS_SUCCESS;
    l_msg_count                      NUMBER;
    l_msg_data                       VARCHAR2(1000);
    l_init_msg_list                  VARCHAR2(3)     := 'F';
    l_new_chr_id                     NUMBER;
    --  l_renew_in_parameters_rec        renew_in_parameters_rec;
    l_renew_in_parameters_rec OKC_RENEW_PVT.renew_in_parameters_rec;

    l_contract_id              number;
    l_contract_number          okc_k_headers_v.contract_number%type;
    l_contract_version         varchar2(9);
    l_contract_modifier        okc_k_headers_v.contract_number_modifier%type;
    l_object_version_number    number;
    l_new_contract_number      okc_k_headers_v.contract_number%type;
    l_new_contract_modifier    okc_k_headers_v.contract_number_modifier%type;
    l_start_date               date;
    l_end_date                 date;
    l_new_end_date             date;
    l_orig_start_date          date;
    l_orig_end_date            date;
    l_uom_code                 okx_units_of_measure_v.uom_code%type;
    l_duration                 number;
    l_context                  VARCHAR2(30);
    l_perpetual_flag           VARCHAR2(1);


    l_default_contract_number  okc_k_headers_v.contract_number%type;

    -- get new start date and end date
   /* CURSOR c_new_start_date IS
    SELECT contract_number, end_date + 1, end_date + 1 + (end_date - start_date)
    FROM   okc_k_headers_v
    where  id = p_contract_id;*/
    CURSOR c_get_dates IS
    SELECT contract_number, start_date, end_date
    FROM   okc_k_headers_v
    where  id = p_contract_id;

BEGIN


    If p_contract_id = OKC_API.G_MISS_NUM Then
           l_contract_id := Null;
    Else
           l_contract_id := p_contract_id;
    End If;
    If p_contract_number = OKC_API.G_MISS_CHAR Then
           l_contract_number := Null;
    Else
    	  l_contract_number := p_contract_number;
    End If;
    If p_contract_version = OKC_API.G_MISS_CHAR Then
           l_contract_version := Null;
    Else
       l_contract_version := p_contract_version;
    End If;
    If p_contract_modifier = OKC_API.G_MISS_CHAR Then
           l_contract_modifier := Null;
    Else
       l_contract_modifier := p_contract_modifier;
    End If;
    If p_object_version_number =  OKC_API.G_MISS_NUM Then
           l_object_version_number := Null;
    Else
       l_object_version_number := p_object_version_number;
    End If;
    If p_new_contract_number =  OKC_API.G_MISS_CHAR Then
           l_new_contract_number := Null;
    Else
      l_new_contract_number := p_new_contract_number;
    End If;
    If p_new_contract_modifier =  OKC_API.G_MISS_CHAR Then
           l_new_contract_modifier := Null;
    Else
      l_new_contract_modifier := p_new_contract_modifier;
    End If;
    If p_start_date = OKC_API.G_MISS_DATE Then
           l_start_date := Null;
    Else
      l_start_date := p_start_date;
    End If;
    If p_end_date = OKC_API.G_MISS_DATE Then
           l_end_date := Null;
    Else
      l_end_date := p_end_date;
    End If;
    If p_orig_start_date = OKC_API.G_MISS_DATE Then
           l_orig_start_date := Null;
    Else
       l_orig_start_date := p_orig_start_date;
    End If;
    If p_orig_end_date = OKC_API.G_MISS_DATE Then
           l_orig_end_date := Null;
    else
       l_orig_end_date := p_orig_end_date;
    End If;
    If p_uom_code = OKC_API.G_MISS_CHAR Then
           l_uom_code := Null;
    else
    	l_uom_code := p_uom_code;
    End If;
    If p_duration = OKC_API.G_MISS_NUM Then
           l_duration := Null;
    else
      l_duration := p_duration;
    End If;
--
    If p_context= OKC_API.G_MISS_CHAR Then
           l_context:= Null;
    ELSE
           l_context := p_context;
    End If;
    If p_perpetual_flag= OKC_API.G_MISS_CHAR Then
           l_perpetual_flag:= Null;
    ELSE
           l_perpetual_flag:=p_perpetual_flag;
    End If;

    -- default contract number
    l_new_contract_modifier := fnd_profile.value('OKC_CONTRACT_IDENTIFIER')|| sysdate || To_char(sysdate,' HH24:MI:SS');

    -- get start date (and end date if required) of new contract (i.e. end date of old contract + 1)
    OPEN  c_get_dates;
    FETCH c_get_dates INTO l_default_contract_number, l_orig_start_date, l_orig_end_date;
    CLOSE c_get_dates;

    IF l_new_contract_number IS NULL THEN
       l_new_contract_number := l_default_contract_number;
    END IF;
    l_start_date := l_orig_end_date + 1;
    IF l_duration IS NULL OR l_uom_code IS NULL THEN
     -- get new duration and period using the orig start date and end date
        okc_time_util_pub.get_duration
                                 (l_orig_start_date,
                                  l_orig_end_date,
                                  l_duration,
                                  l_uom_code,
                                  l_return_status
                                  );

        l_end_date :=  OKC_TIME_UTIL_PUB.get_enddate(l_start_date,
                                            l_uom_code,
                                            l_duration
                                            );

    END IF;

    -- assign params to each field in rec
    l_renew_in_parameters_rec.p_contract_id           := l_contract_id;
    l_renew_in_parameters_rec.p_contract_number       := l_contract_number;
    l_renew_in_parameters_rec.p_contract_version      := l_contract_version;
    l_renew_in_parameters_rec.p_contract_modifier     := l_contract_modifier;
    l_renew_in_parameters_rec.p_object_version_number := l_object_version_number;
    l_renew_in_parameters_rec.p_new_contract_number   := l_new_contract_number;
    l_renew_in_parameters_rec.p_new_contract_modifier := l_new_contract_modifier;
    l_renew_in_parameters_rec.p_start_date            := l_start_date;
    l_renew_in_parameters_rec.p_end_date              := l_end_date;
    l_renew_in_parameters_rec.p_orig_start_date       := l_orig_start_date;
    l_renew_in_parameters_rec.p_orig_end_date         := l_orig_end_date;
    l_renew_in_parameters_rec.p_uom_code              := l_uom_code;
    l_renew_in_parameters_rec.p_duration              := l_duration;
    l_renew_in_parameters_rec.p_context               := l_context;
    l_renew_in_parameters_rec.p_perpetual_flag        := l_perpetual_flag;

    -- call okc_renew_pub.pre_renew.
    OKC_RENEW_PUB.PRE_RENEW( p_api_version             => l_api_version
                            ,p_init_msg_list           => OKC_API.G_TRUE
                            ,x_return_status           => l_return_status
                            ,x_msg_count               => l_msg_count
                            ,x_msg_data                => l_msg_data
                            ,x_contract_id             => l_new_chr_id
                            ,p_renew_in_parameters_rec => l_renew_in_parameters_rec
		            ,p_renewal_called_from_ui  => 'N'
                            ,p_do_commit               => OKC_API.G_TRUE );

    x_msg_count     := l_msg_count;
    x_return_status := l_return_status;
    x_msg_data      := l_msg_data;
    -- x_contract_id   := l_new_chr_id;

    IF x_return_status = okc_api.g_ret_sts_success THEN
       OKC_API.set_message(p_app_name     => 'OKC',
			                  p_msg_name     => 'OKC_OC_SUCCESS',
		                     p_token1       => 'PROCESS',
	                        p_token1_value => 'Renewal');
    ELSE
       OKC_API.SET_MESSAGE(p_app_name     => 'OKC',
                           p_msg_name     => 'OKC_OC_FAILED',
                           p_token1       => 'PROCESS',
                           p_token1_value => 'Renewal',
                           p_token2       => 'MESSAGE1',
                           p_token2_value => 'Error Stack is :',
                           p_token3       => 'MESSAGE2',
                           p_token3_value => l_msg_data);
    END IF;


EXCEPTION
  when others then
  OKC_API.SET_MESSAGE(p_app_name     => 'OKC',
		      p_msg_name     => 'OKC_OC_FAILED',
		      p_token1       => 'PROCESS',
	              p_token1_value => 'Renewal',
		      p_token2       => 'MESSAGE1',
	              p_token2_value => 'Error Stack is :',
	              p_token3       => 'MESSAGE2',
		      p_token3_value => l_msg_data);
   x_return_status := l_return_status;

END RENEWAL_OUTCOME;

END OKC_RENEWAL_OUTCOME_PUB;

/
