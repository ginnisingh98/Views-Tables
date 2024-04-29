--------------------------------------------------------
--  DDL for Package Body OKL_CREATE_ADJST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREATE_ADJST_PUB" AS
/* $Header: OKLPOCAB.pls 120.2.12010000.2 2009/08/06 08:45:36 nikshah ship $ */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              create_adjustments_pub                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the main routine to create an adjustment in AR       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Bruno Vaghela  16-AUG-02  Created                                      |
 |    Bruno Vaghela  21-JAN-03  Process now creates a OUTPUT file.           |
 |    Syed Nizam     29-APR-08  Bug 6727171 -- Modified error handling       |
 +===========================================================================*/

PROCEDURE create_adjustments_pub( p_api_version	     IN	 NUMBER
  				                 ,p_init_msg_list    IN	 VARCHAR2 DEFAULT OKL_API.G_FALSE
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count	     OUT NOCOPY NUMBER
                                 ,x_msg_data	     OUT NOCOPY VARCHAR2
                                ) IS

l_return_status          VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
l_api_version			 NUMBER := 1;
l_init_msg_list			 VARCHAR2(1);
l_msg_count				 NUMBER;
l_msg_data				 VARCHAR(2000);
l_new_adj_id				 NUMBER;

BEGIN

    SAVEPOINT save_Insert_row;

    l_api_version      := p_api_version;
    l_init_msg_list    := p_init_msg_list;

    -- customer pre-processing



    OKL_CREATE_ADJST_PVT.create_adjustments ( p_api_version => p_api_version
                                             ,p_init_msg_list => p_init_msg_list
                                             ,x_return_status => l_return_status
		 	                                 ,x_msg_count => l_msg_count
                                             ,x_msg_data => l_msg_data
					     ,x_new_adj_id => l_new_adj_id
                                            );

/* Bug 6727171 Start

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
            l_return_status := x_return_status;
        END IF;
    END IF;
    Bug 6727171 End */

    --Bug 6727171 Start
    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	    RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Bug 6727171 End

    --Assign value to OUT variables

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('CREATE_ADJUSTMENTS_PUB','insert_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END create_adjustments_pub;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              iex_create_adjustments_pub                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the main routine to create an adjustment in AR       |
 |              specifically for IEX guys.                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_api_name                                              |
 |                   p_api_version                                           |
 |                   p_init_msg_list                                         |
 |                   p_commit_flag                                           |
 |                   p_psl_id                                                |
 |                   p_chk_approval_limits                                   |
 |            : OUT:                                                         |
 |                   x_new_adj_id                                            |
 |                   x_return_status                                         |
 |                   x_msg_count					                         |
 |		             x_msg_data		                                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Bruno Vaghela  09-OCT-02  Created                                      |
 +===========================================================================*/

PROCEDURE iex_create_adjustments_pub( p_api_version	         IN  NUMBER
  				                     ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                                     ,p_commit_flag          IN  VARCHAR2 DEFAULT OKL_API.G_TRUE
                                     ,p_psl_id               IN  NUMBER
                                     ,p_chk_approval_limits  IN  VARCHAR2 DEFAULT OKL_API.G_TRUE
                                     ,x_new_adj_id           OUT NOCOPY NUMBER
                                     ,x_return_status        OUT NOCOPY VARCHAR2
                                     ,x_msg_count	         OUT NOCOPY NUMBER
                                     ,x_msg_data	         OUT NOCOPY VARCHAR2
                                    ) IS

l_return_status          VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
l_api_version			 NUMBER := 1;
l_init_msg_list			 VARCHAR2(1);
l_msg_count				 NUMBER;
l_msg_data				 VARCHAR(2000);

BEGIN

    SAVEPOINT save_Insert_row;

    l_api_version      := p_api_version;
    l_init_msg_list    := p_init_msg_list;

    -- customer pre-processing



    OKL_CREATE_ADJST_PVT.iex_create_adjustments ( p_api_version
                                                 ,p_init_msg_list
                                                 ,p_commit_flag
                                                 ,p_psl_id
                                                 ,p_chk_approval_limits
                                                 ,x_new_adj_id
                                                 ,l_return_status
		 	                                     ,l_msg_count
                                                 ,l_msg_data
                                                );

/*Bug 6727171 Start
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
            l_return_status := x_return_status;
        END IF;
    END IF;
Bug 6727171 End */

      --Bug 6727171 Start
    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	    RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Bug 6727171 End



    --Assign value to OUT variables

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('IEX_CREATE_ADJUSTMENTS_PUB','insert_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END iex_create_adjustments_pub;

 PROCEDURE create_adjustments_conc ( errbuf  	  OUT NOCOPY   VARCHAR2
                                    ,retcode 	  OUT NOCOPY   NUMBER )
IS

  l_api_version     NUMBER := 1;
  l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_msg_count     	NUMBER;
  l_msg_data    	VARCHAR2(450);
  l_init_msg_list   VARCHAR2(1);

  l_msg_index_out   NUMBER :=0;
  l_error_msg_rec 		Okl_Accounting_Util.Error_message_Type;

BEGIN


	OKL_CREATE_ADJST_PUB.create_adjustments_pub ( p_api_version     => l_api_version
                                                 ,p_init_msg_list   => l_init_msg_list
                                                 ,x_return_status   => l_return_status
			                                     ,x_msg_count       => l_msg_count
                                                 ,x_msg_data        => l_msg_data
                                                );

    FND_FILE.PUT_LINE (FND_FILE.LOG, '*****************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'OKL Create AR Adjustment Process Program');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '*****************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Program Run Date:'||sysdate);
    FND_FILE.PUT_LINE (FND_FILE.LOG, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Detailed Error Message For Each Processed Line ...');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '----------------------------------------------------------------------------');

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*****************************************'
);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'OKL Create AR Adjustment Process Program')
;
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*****************************************'
);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date:'||sysdate);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '******************************************
*****');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '******************************************
*****');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Detailed Error Message For Each Processed
Line ...');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '------------------------------------------
----------------------------------');

    BEGIN

        Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
            FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
            LOOP
                FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
                FND_FILE.PUT_LINE (FND_FILE.LOG, '----------------------------------------------------------------------------');

                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_error_msg_rec(i));
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '------------------------------
----------------------------------------------');
            END LOOP;
        END IF;
/*
        FOR i in 1..lx_msg_count LOOP
            fnd_msg_pub.get (p_msg_index => i,
                             p_encoded => 'F',
                             p_data => lx_msg_data,
                             p_msg_index_out => l_msg_index_out);

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || lx_msg_data);
        END LOOP;
*/
    EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);

        FND_FILE.PUT_LINE (FND_FILE.LOG,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    END;


EXCEPTION
    WHEN OTHERS THEN
         NULL ;
END create_adjustments_conc;

END OKL_CREATE_ADJST_PUB;

/
