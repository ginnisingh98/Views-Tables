--------------------------------------------------------
--  DDL for Package Body OKL_ARINTF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ARINTF_PUB" AS
/* $Header: OKLPAINB.pls 120.4.12010000.2 2008/11/05 15:04:52 gboomina ship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE Get_REC_FEEDER
  ---------------------------------------------------------------------------
  PROCEDURE Get_REC_FEEDER( p_api_version       IN NUMBER,
                            p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
                            p_trx_date_from    IN  DATE DEFAULT NULL,
                            p_trx_date_to      IN  DATE DEFAULT NULL,
                            p_assigned_process IN  VARCHAR2) IS


    l_xsiv_rec              xsiv_rec_type;
    l_data                  VARCHAR2(100);
    l_api_name              CONSTANT VARCHAR2(30)  := 'Get_REC_FEEDER';
    l_count                 NUMBER ;
    l_return_status         VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_trx_date_from         DATE;
    l_trx_date_to           DATE;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

--  l_xsiv_rec := p_xsiv_rec;
    l_trx_date_from := p_trx_date_from;
    l_trx_date_to   := p_trx_date_to;



	-- call main process api to load the AR Interface Table

    okl_ARIntf_pvt.Get_REC_FEEDER(p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                              	  x_return_status => l_return_status,
                              	  x_msg_count     => x_msg_count,
                              	  x_msg_data      => x_msg_data,
                                  p_trx_date_from => l_trx_date_from,
                                  p_trx_date_to   => l_trx_date_to,
                                  p_assigned_process    => p_assigned_process);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
--  l_xsiv_rec := x_xsiv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_FILE.put_line(fnd_file.log,'ERROR (OKL_ARIntf_PUB.Get_REC_FEEDER): '||SQLERRM );
        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE okl_parallel_processes
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        FND_FILE.put_line(fnd_file.log,'ERROR (OKL_ARIntf_PUB.Get_REC_FEEDER): '||SQLERRM );
        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE okl_parallel_processes
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN

        FND_FILE.put_line(fnd_file.log,'ERROR (OKL_ARIntf_PUB.Get_REC_FEEDER): '||SQLERRM );
        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE okl_parallel_processes
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ARIntf_PUB','Get_REC_FEEDER');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END Get_REC_FEEDER;

  PROCEDURE Get_REC_FEEDER_CONC
  ( errbuf                         OUT NOCOPY VARCHAR2
  , retcode                        OUT NOCOPY NUMBER
  , p_trx_date_from                IN  VARCHAR2
  , p_trx_date_to                  IN  VARCHAR2
  , p_assigned_process             IN  VARCHAR2
  )  is

  l_api_vesrions   NUMBER := 1;
  lx_msg_count     NUMBER;
  l_trx_date_from   DATE;
  l_trx_date_to     DATE;
  l_count1          NUMBER;
  l_count2          NUMBER;
  l_count           NUMBER;
  lx_return_status  VARCHAR2(1);

    BEGIN

     IF p_trx_date_from IS NOT NULL THEN
    l_trx_date_from :=  FND_DATE.CANONICAL_TO_DATE(p_trx_date_from);
    END IF;

    IF p_trx_date_to IS NOT NULL THEN
    l_trx_date_to :=  FND_DATE.CANONICAL_TO_DATE(p_trx_date_to);
    END IF;

    FND_FILE.put_line(fnd_file.log,'p_trx_date_from'||p_trx_date_from );
    FND_FILE.put_line(fnd_file.log,'p_trx_date_to'||p_trx_date_to );
    FND_FILE.put_line(fnd_file.log,'p_assigned_process'||p_assigned_process);

    IF p_assigned_process IS NOT NULL THEN
           Get_REC_FEEDER( p_api_version       => l_api_vesrions,
                            p_init_msg_list    => OKC_API.G_FALSE,
                        	x_return_status    => lx_return_status,
                        	x_msg_count        => lx_msg_count,
                        	x_msg_data         => errbuf,
                            p_trx_date_from    => l_trx_date_from ,
                            p_trx_date_to      => l_trx_date_to,
                            p_assigned_process => p_assigned_process);

    ELSE
           FND_FILE.put_line(fnd_file.log,'*** ============================================================ ***' );
           FND_FILE.put_line(fnd_file.log,'*** Please Submit Receivables Invoice Transfer - Master Program. ***' );
           FND_FILE.put_line(fnd_file.log,'*** ============================================================ ***' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.put_line(fnd_file.log,'ERROR (OKL_ARIntf_PUB.Get_REC_FEEDER_CONC): '||SQLERRM );
        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE okl_parallel_processes
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

  END Get_REC_FEEDER_CONC;



END OKL_ARIntf_PUB;

/
