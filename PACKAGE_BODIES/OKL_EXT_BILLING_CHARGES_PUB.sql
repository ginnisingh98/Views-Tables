--------------------------------------------------------
--  DDL for Package Body OKL_EXT_BILLING_CHARGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EXT_BILLING_CHARGES_PUB" AS
/* $Header: OKLPBCGB.pls 115.6 2004/04/13 10:32:51 rnaik noship $ */

-------------------------------------------------------------------------
-- Procedure BILLING_CHARGES to bill imported data from external sources.
-------------------------------------------------------------------------

PROCEDURE billing_charges
	(p_api_version		  IN  NUMBER
	,p_init_msg_list	  IN  VARCHAR2	DEFAULT Okl_Api.G_FALSE
	,x_return_status	  OUT NOCOPY VARCHAR2
	,x_msg_count		  OUT NOCOPY NUMBER
	,x_msg_data			  OUT NOCOPY VARCHAR2
	,p_name               IN  VARCHAR2	DEFAULT NULL
	,p_sequence_number    IN  NUMBER		DEFAULT NULL
	,p_date_transmission  IN  DATE		DEFAULT NULL
	,p_origin             IN  VARCHAR2	DEFAULT NULL
	,p_destination        IN  VARCHAR2	DEFAULT NULL) IS

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------

	l_api_version		  NUMBER;
	l_init_msg_list	  	  VARCHAR2(1);
	l_msg_data			  VARCHAR2(2000);
	l_api_name			  CONSTANT VARCHAR2(30)  := 'BILLING_CHARGES';
	l_return_status		  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_data				  VARCHAR2(2000);
	l_count				  NUMBER;

	l_name               OKL_BLLNG_CHRG_HDRS_V.name%TYPE;
	l_sequence_number    OKL_BLLNG_CHRG_HDRS_V.sequence_number%TYPE;
	l_date_transmission  OKL_BLLNG_CHRG_HDRS_V.date_transmission%TYPE;
	l_origin             OKL_BLLNG_CHRG_HDRS_V.origin%TYPE;
	l_destination        OKL_BLLNG_CHRG_HDRS_V.destination%TYPE;

BEGIN

	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status		:= Fnd_Api.G_RET_STS_SUCCESS;

	SAVEPOINT sp_bill_charges;

	l_name               := p_name;
	l_sequence_number    := p_sequence_number;
	l_date_transmission  := p_date_transmission;
	l_origin             := p_origin;
	l_destination        := p_destination;

	l_api_version		 := p_api_version;
	------------------------------------------------------------
	------------------------------------------------------------


	------------------------------------------------------------
	------------------------------------------------------------


	------------------------------------------------------------
	-- Call process API for billing charges
	------------------------------------------------------------
	Okl_Ext_Billing_Charges_Pvt.billing_charges
			(p_api_version		  => l_api_version
			,p_init_msg_list	  => l_init_msg_list
			,x_return_status	  => l_return_status
			,x_msg_count		  => l_count
			,x_msg_data			  => l_data
			,p_name               => l_name
			,p_sequence_number    => l_sequence_number
			,p_date_transmission  => l_date_transmission
			,p_origin             => l_origin
			,p_destination        => l_destination);

	IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
		RAISE Fnd_Api.G_EXC_ERROR;
	ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
		RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

	------------------------------------------------------------
	------------------------------------------------------------


	------------------------------------------------------------
	------------------------------------------------------------



  EXCEPTION

	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Fnd_Api.G_EXC_ERROR THEN

		ROLLBACK TO sp_bill_charges;
		x_return_status := Fnd_Api.G_RET_STS_ERROR;
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);

	WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN

		ROLLBACK TO sp_bill_charges;
		x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);

	WHEN OTHERS THEN

		x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		Fnd_Msg_Pub.ADD_EXC_MSG (
			p_pkg_name		=> G_PKG_NAME,
			p_procedure_name	=> l_api_name);
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);


END billing_charges;



PROCEDURE billing_charges_conc
  	(errbuf  			  OUT NOCOPY   VARCHAR2
    ,retcode 			  OUT NOCOPY   NUMBER
	,p_name  			  IN    VARCHAR2	DEFAULT NULL
	,p_sequence_number    IN 	NUMBER		DEFAULT NULL
	,p_date_transmission  IN	DATE		DEFAULT NULL
	,p_origin             IN	VARCHAR2	DEFAULT NULL
	,p_destination        IN 	VARCHAR2	DEFAULT NULL)
IS

  l_api_version         NUMBER := 1;
  lx_msg_count     		NUMBER;
  l_return_status		VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_date_transmission   DATE;
  l_count1          NUMBER :=0;
  l_count2          NUMBER :=0;
  l_count           NUMBER :=0;
  I                 NUMBER :=0;
  l_msg_index_out   NUMBER :=0;
  lx_msg_data    	VARCHAR2(450);
  lx_return_status  VARCHAR2(1);
  l_data			VARCHAR2(2000);
  l_init_msg_list   VARCHAR2(1);

BEGIN


    IF p_date_transmission IS NOT NULL THEN
       l_date_transmission :=  FND_DATE.CANONICAL_TO_DATE(p_date_transmission);
    END IF;


    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Name  	  		 = ' ||p_name);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sequence Number    = ' ||p_sequence_number);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Date Transmission  = ' ||p_date_transmission);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Origin			 = ' ||p_origin);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Destination		 = ' ||p_destination);

	Okl_Ext_Billing_Charges_Pub.billing_charges
			 (p_api_version		  => l_api_version
			 ,p_init_msg_list	  => l_init_msg_list
			 ,x_return_status	  => l_return_status
			 ,x_msg_count		  => l_count
			 ,x_msg_data		  => l_data
			 ,p_name              => p_name
			 ,p_sequence_number   => p_sequence_number
			 ,p_date_transmission => p_date_transmission
			 ,p_origin            => p_origin
			 ,p_destination       => p_destination);


    BEGIN

	  IF (l_count > 0 ) THEN
         FOR i IN 1..l_count LOOP
            fnd_msg_pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);

    		FND_FILE.PUT_LINE (FND_FILE.OUTPUT,TO_CHAR(i) || ': ' || lx_msg_data);
         END LOOP;
	  END IF;
    EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);

    END;
EXCEPTION
    WHEN OTHERS THEN
         NULL ;
END billing_charges_conc;

END Okl_Ext_Billing_Charges_Pub;

/
