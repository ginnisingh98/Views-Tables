--------------------------------------------------------
--  DDL for Package Body PSA_MULTIFUND_DISTRIBUTION_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MULTIFUND_DISTRIBUTION_EXT" AS
/* $Header: PSAMFEXB.pls 120.2 2006/09/13 12:38:57 agovil noship $ */

-- Parameters:

-- p_init_msg_list (Optional) (Default FALSE) :
-- Allows API callers to request the initialization of the message list.

-- x_return_status :
-- Reports the API overall return status defined as follows :
                -- G_RET_STS_SUCCESS	 CONSTANT VARCHAR2(1):='S'; -- execution success
	        -- G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1):='U'; -- execution error

-- x_msg_count : Holds the number of messages in the API message list.

-- x_msg_data  : The actual message in an encoded format.

-- p_sob_id    : Set of Books ID

-- p_doc_id    : Document ID (customer_trx_id) for which multi-fund distributions are to be created.


  FUNCTION CREATE_DISTRIBUTIONS_PUB
          (p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
           x_return_status     	      OUT NOCOPY VARCHAR2,
           x_msg_count         	      OUT NOCOPY NUMBER,
           x_msg_data          	      OUT NOCOPY VARCHAR2,
           p_sob_id                   IN  NUMBER,
           p_doc_id                   IN  NUMBER,
	   p_report_only	      IN  VARCHAR2 DEFAULT 'N') RETURN BOOLEAN
  IS
	-- Bug 3837120 .. Commented the pragma
  	-- PRAGMA AUTONOMOUS_TRANSACTION;

 	l_errbuf	VARCHAR2(3000);
  	l_retcode	VARCHAR2(3000);
  	l_run_num	NUMBER;
   	l_error_mesg    VARCHAR2(3000);

  BEGIN


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*
      If Activity is (T)ransaction, Multifund Transaction, Cash Receipts and Adjustments will be processed
      If Activity is (M)iscellanous Receipt, Misc. receipts will be processed
      If Activity is (A)ll, all the Multifund distributions will be processed.
    */

    -- Bug 3837120 .. Added new parameter p_report_only
    IF NOT PSA_MF_CREATE_DISTRIBUTIONS.create_distributions
    (
     errbuf             => l_errbuf,
     retcode            => l_retcode,
     p_mode             => 'A',
     p_document_id      => p_doc_id,
     p_set_of_books_id  => p_sob_id,
     run_num		=> l_run_num,
     p_error_message	=> l_error_mesg,
     p_report_only      => p_report_only
    )  THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (p_count =>  x_msg_count,
     p_data  =>  x_msg_data);
     x_msg_data := x_msg_data||l_error_mesg;

    -- Need to commit before exiting autonomous transaction

    -- Bug 3837120 .. Commented out COMMIT
    -- COMMIT;

    EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  		FND_MSG_PUB.Count_And_Get
	  		(p_count => x_msg_count ,
	        	 p_data  => x_msg_data  );
      x_msg_data := x_msg_data||l_error_mesg;

	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  		FND_MSG_PUB.Count_And_Get
	  		(p_count => x_msg_count ,
	        	 p_data  => x_msg_data  );
      x_msg_data := x_msg_data||l_error_mesg;

  END CREATE_DISTRIBUTIONS_PUB;

END PSA_MULTIFUND_DISTRIBUTION_EXT;

/
