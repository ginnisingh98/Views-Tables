--------------------------------------------------------
--  DDL for Package Body AR_VIEW_TERM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_VIEW_TERM_GRP" AS
/* $Header: ARVTERMB.pls 120.1 2005/01/14 19:43:48 jbeckett noship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'AR_VIEW_TERM_GRP';
G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/
TYPE pay_now_cache_table IS TABLE OF pay_now_record INDEX BY BINARY_INTEGER;

pay_now_cache		pay_now_cache_table;

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/

 /*==========================================================================+
 | PROCEDURE                                                                 |
 |    pay_now_amounts                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure returns pay now amounts for a given line, tax and       |
 |    freight amount and term_id                                             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN  : p_term_id                                              |
 |                    p_line_amount       				     |
 |                    p_tax_amount					     |
 |                    p_freight_amount       				     |
 |                                                                           |
 |              OUT : x_pay_now_line_amount                                  |
 |                    x_pay_now_tax_amount                                   |
 |                    x_pay_now_freight_amount                               |
 |                    x_pay_now_total_amount                               |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-NOV-04  JBECKETT Created                                           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE pay_now_amounts(
           -- Standard API parameters.
                p_api_version      	IN  NUMBER,
                p_init_msg_list    	IN  VARCHAR2,
                p_validation_level 	IN  NUMBER,
		p_term_id 		IN NUMBER,
		p_currency_code 	IN fnd_currencies.currency_code%TYPE,
		p_line_amount		IN NUMBER,
		p_tax_amount		IN NUMBER,
                p_freight_amount	IN NUMBER,
		x_pay_now_line_amount   OUT NOCOPY NUMBER,
		x_pay_now_tax_amount    OUT NOCOPY NUMBER,
		x_pay_now_freight_amount OUT NOCOPY NUMBER,
		x_pay_now_total_amount	OUT NOCOPY NUMBER,
                x_return_status    	OUT NOCOPY VARCHAR2,
                x_msg_count        	OUT NOCOPY NUMBER,
                x_msg_data         	OUT NOCOPY VARCHAR2)
IS

  l_api_name			CONSTANT VARCHAR2(30)	:= 'pay_now_amounts';
  l_api_version           	CONSTANT NUMBER 	:= 1.0;

  l_pay_now_percent 		NUMBER;
  l_pay_now_line_amount		NUMBER;
  l_pay_now_line_amt_rnd	NUMBER;
  l_pay_now_tax_amount		NUMBER;
  l_pay_now_tax_amt_rnd		NUMBER;
  l_pay_now_freight_amount	NUMBER;
  l_pay_now_freight_amt_rnd	NUMBER;

  CURSOR c_term(p_term_id IN NUMBER) IS
  SELECT NVL(base_amount,100),
         first_installment_code
  FROM   ra_terms
  WHERE  term_id = p_term_id;

  CURSOR c_term_line (p_term_id IN NUMBER) IS
  SELECT NVL(SUM(tl.relative_amount),0),
         NVL(SUM(DECODE(tl.sequence_num,1,1,0)),0)
  FROM   ra_terms_lines tl
  WHERE  tl.term_id = p_term_id
  AND    tl.due_days = 0;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('AR_VIEW_TERM_GRP.pay_now_amounts()+');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
      	    	    	    	 	p_api_version        	,
        	    	 		l_api_name 	    	,
    	    	    	    		G_PKG_NAME )
  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Unexpected error: wrong API version '||sqlerrm||
                     ' at AR_VIEW_TERM_GRP.pay_now_amounts()+');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if term_id is in cache, and insert if not
  IF NOT pay_now_cache.EXISTS(p_term_id) THEN
    OPEN c_term(p_term_id);
    FETCH c_term INTO pay_now_cache(p_term_id).base_amount,
		      pay_now_cache(p_term_id).first_installment_code;
    IF c_term%NOTFOUND THEN
       FND_MESSAGE.set_name('AR','AR_TAPI_INVALID_TERMS_ID');
       FND_MESSAGE.set_token('INVALID_VALUE',p_term_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_term;

    OPEN c_term_line(p_term_id);
    FETCH c_term_line INTO pay_now_cache(p_term_id).relative_amount_total,
			   pay_now_cache(p_term_id).first_installment_count;
    CLOSE c_term_line;
  END IF;
  -- Calculate pay now amounts
  l_pay_now_percent := pay_now_cache(p_term_id).relative_amount_total / pay_now_cache(p_term_id).base_amount;

  l_pay_now_line_amount := p_line_amount * l_pay_now_percent;

  BEGIN
    l_pay_now_line_amt_rnd := arpcurr.CurrRound(l_pay_now_line_amount, p_currency_code);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.set_name('AR','AR_CC_INVALID_CURRENCY');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
  END;

  x_pay_now_line_amount := l_pay_now_line_amt_rnd;
  IF pay_now_cache(p_term_id).first_installment_code = 'ALLOCATE' THEN
     l_pay_now_tax_amount := p_tax_amount * l_pay_now_percent;
     l_pay_now_tax_amt_rnd := arpcurr.CurrRound(l_pay_now_tax_amount, p_currency_code);
     l_pay_now_freight_amount := p_freight_amount * l_pay_now_percent;
     l_pay_now_freight_amt_rnd := arpcurr.CurrRound(l_pay_now_freight_amount, p_currency_code);
  ELSE
     l_pay_now_tax_amt_rnd := p_tax_amount * pay_now_cache(p_term_id).first_installment_count;
     l_pay_now_freight_amt_rnd := p_freight_amount * pay_now_cache(p_term_id).first_installment_count;
  END IF;

  x_pay_now_tax_amount := l_pay_now_tax_amt_rnd;
  x_pay_now_freight_amount := l_pay_now_freight_amt_rnd;
  x_pay_now_total_amount := l_pay_now_line_amt_rnd + l_pay_now_tax_amt_rnd + l_pay_now_freight_amt_rnd;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('AR_VIEW_TERM_GRP.pay_now_amounts()-');
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Unexpected error '||sqlerrm||
                             ' at ar_view_term_grp.pay_now_amounts()+');
                END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('20001 error '||
                             ' at ar_view_term_grp.pay_now_amounts()+');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Unexpected error '||sqlerrm||
                             ' at ar_view_term_grp.pay_now_amounts()+');
                  END IF;
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		  IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		  THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		  END IF;
		END IF;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
END pay_now_amounts;

 /*==========================================================================+
 | PROCEDURE                                                                 |
 |    pay_now_amounts (overloaded)                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure returns pay now amounts for a given line, tax and       |
 |    freight amount and term_id - this version of the procedure has input/  |
 |    output parameters in tables.                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN OUT : p_amounts_tbl                                       |
 |                                                                           |
 |              OUT :    x_pay_now_summary_rec                               |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-NOV-04  JBECKETT Created                                           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE pay_now_amounts(
                p_api_version      	IN  NUMBER,
                p_init_msg_list    	IN  VARCHAR2,
                p_validation_level 	IN  NUMBER,
		p_currency_code 	IN  fnd_currencies.currency_code%TYPE,
		p_amounts_tbl           IN OUT NOCOPY ar_view_term_grp.amounts_table,
		x_pay_now_summary_rec	OUT NOCOPY ar_view_term_grp.summary_amounts_rec,
                x_return_status    	OUT NOCOPY VARCHAR2,
                x_msg_count        	OUT NOCOPY NUMBER,
                x_msg_data         	OUT NOCOPY VARCHAR2)
IS
  l_api_name			CONSTANT VARCHAR2(30)	:= 'pay_now_amounts';
  l_api_version           	CONSTANT NUMBER 	:= 1.0;
  l_msg_count				NUMBER;

  l_pay_now_line_amount			NUMBER;
  l_pay_now_tax_amount			NUMBER;
  l_pay_now_freight_amount		NUMBER;
  l_pay_now_total_amount		NUMBER;
  l_pay_now_line_amt_sum		NUMBER;
  l_pay_now_tax_amt_sum			NUMBER;
  l_pay_now_freight_amt_sum		NUMBER;
  l_pay_now_total_sum			NUMBER;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('AR_VIEW_TERM_GRP.pay_now_amounts(2)+');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
      	    	    	    	 	p_api_version        	,
        	    	 		l_api_name 	    	,
    	    	    	    		G_PKG_NAME )
  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Unexpected error: wrong API version '||sqlerrm||
                     ' at AR_VIEW_TERM_GRP.pay_now_amounts()+');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  l_pay_now_line_amt_sum		:= 0;
  l_pay_now_tax_amt_sum			:= 0;
  l_pay_now_freight_amt_sum		:= 0;
  l_pay_now_total_sum			:= 0;

  FOR i in p_amounts_tbl.FIRST..p_amounts_tbl.LAST LOOP

    ar_view_term_grp.pay_now_amounts
       (p_api_version           	=> 1.0,
        p_init_msg_list         	=> FND_API.G_FALSE,
        p_term_id               	=> p_amounts_tbl(i).term_id,
        p_currency_code         	=> p_currency_code,
        p_line_amount           	=> p_amounts_tbl(i).line_amount,
        p_tax_amount            	=> p_amounts_tbl(i).tax_amount,
        p_freight_amount      	  	=> p_amounts_tbl(i).freight_amount,
        x_pay_now_line_amount		=> l_pay_now_line_amount,
        x_pay_now_tax_amount		=> l_pay_now_tax_amount,
        x_pay_now_freight_amount	=> l_pay_now_freight_amount,
        x_pay_now_total_amount 		=> l_pay_now_total_amount,
        x_return_status         	=> x_return_status,
        x_msg_count             	=> l_msg_count,
        x_msg_data              	=> x_msg_data);

        p_amounts_tbl(i).line_amount := l_pay_now_line_amount;
        p_amounts_tbl(i).tax_amount := l_pay_now_tax_amount;
        p_amounts_tbl(i).freight_amount := l_pay_now_freight_amount;
        p_amounts_tbl(i).total_amount := l_pay_now_total_amount;

    x_msg_count := x_msg_count + l_msg_count;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_pay_now_line_amt_sum := l_pay_now_line_amt_sum + l_pay_now_line_amount;
    l_pay_now_tax_amt_sum := l_pay_now_tax_amt_sum + l_pay_now_tax_amount;
    l_pay_now_freight_amt_sum := l_pay_now_freight_amt_sum + l_pay_now_freight_amount;
    l_pay_now_total_sum := l_pay_now_total_sum + l_pay_now_total_amount;

  END LOOP;

  x_pay_now_summary_rec.line_amount := l_pay_now_line_amt_sum;
  x_pay_now_summary_rec.tax_amount := l_pay_now_tax_amt_sum;
  x_pay_now_summary_rec.freight_amount := l_pay_now_freight_amt_sum;
  x_pay_now_summary_rec.total_amount := l_pay_now_total_sum;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('AR_VIEW_TERM_GRP.pay_now_amounts(2)-');
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Unexpected error '||sqlerrm||
                             ' at ar_view_term_grp.pay_now_amounts(2)+');
                END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('20001 error '||
                             ' at ar_view_term_grp.pay_now_amounts(2)+');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Unexpected error '||sqlerrm||
                             ' at ar_view_term_grp.pay_now_amounts(2)+');
                  END IF;
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		  IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		  THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		  END IF;
		END IF;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
END pay_now_amounts;

END AR_VIEW_TERM_GRP;

/
