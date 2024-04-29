--------------------------------------------------------
--  DDL for Package HZ_PAYMENT_METHOD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PAYMENT_METHOD_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHPYMPS.pls 120.2 2005/08/02 18:53:51 acng noship $*/

TYPE payment_method_rec_type IS RECORD (
   cust_receipt_method_id      NUMBER
  ,cust_account_id             NUMBER
  ,receipt_method_id           NUMBER
  ,primary_flag                VARCHAR2(1) DEFAULT 'Y'
  ,site_use_id                 NUMBER
  ,start_date                  DATE
  ,end_date                    DATE
  ,attribute_category          VARCHAR2(30)
  ,attribute1                  VARCHAR2(150)
  ,attribute2                  VARCHAR2(150)
  ,attribute3                  VARCHAR2(150)
  ,attribute4                  VARCHAR2(150)
  ,attribute5                  VARCHAR2(150)
  ,attribute6                  VARCHAR2(150)
  ,attribute7                  VARCHAR2(150)
  ,attribute8                  VARCHAR2(150)
  ,attribute9                  VARCHAR2(150)
  ,attribute10                 VARCHAR2(150)
  ,attribute11                 VARCHAR2(150)
  ,attribute12                 VARCHAR2(150)
  ,attribute13                 VARCHAR2(150)
  ,attribute14                 VARCHAR2(150)
  ,attribute15                 VARCHAR2(150) );

  -- PROCEDURE create_payment_method
  --
  -- DESCRIPTION
  --     Create payment method.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_rec Payment method record.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_receipt_method_id      Payment method Id.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

PROCEDURE create_payment_method (
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_payment_method_rec        IN payment_method_rec_type,
  x_cust_receipt_method_id    OUT NOCOPY    NUMBER,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2 );

  -- PROCEDURE update_payment_method
  --
  -- DESCRIPTION
  --     Update payment method.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_rec Payment method record.
  --   IN/OUT:
  --     px_last_update_date  Last update date of payment method record.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

PROCEDURE update_payment_method (
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_payment_method_rec        IN payment_method_rec_type,
  px_last_update_date         IN OUT NOCOPY DATE,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2 );

  -- PROCEDURE validate_payment_method
  --
  -- DESCRIPTION
  --     Validate payment method.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create or update flag.
  --     p_payment_method_rec Payment method record.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

PROCEDURE validate_payment_method (
   p_create_update_flag        IN VARCHAR2
  ,p_payment_method_rec        IN payment_method_rec_type
  ,x_return_status             IN OUT NOCOPY VARCHAR2 );

END HZ_PAYMENT_METHOD_PUB;

 

/
