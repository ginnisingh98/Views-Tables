--------------------------------------------------------
--  DDL for Package Body OKL_PAY_CURE_REFUNDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_CURE_REFUNDS_PUB" as
/* $Header: OKLPPCRB.pls 120.2 2006/08/11 10:46:32 gboomina noship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

PROCEDURE create_refund_hdr
             (  p_api_version             IN NUMBER
               ,p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit                  IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec    IN pay_cure_refunds_rec_type
               ,x_cure_refund_header_id   OUT NOCOPY  NUMBER
               ,x_return_status           OUT NOCOPY VARCHAR2
               ,x_msg_count               OUT NOCOPY NUMBER
               ,x_msg_data                OUT NOCOPY VARCHAR2
               )IS

l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_cure_refund_header_id okl_cure_refund_headers_b.cure_refund_header_id%type;
l_pay_cure_refunds_rec pay_cure_refunds_rec_type
                               :=p_pay_cure_refunds_rec;
l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_REFUND_HDR';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;

BEGIN

      SAVEPOINT CREATE_REFUND_HDR;

       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.CREATE_REFUND_HDR');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.CREATE_REFUND_HDR(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_pay_cure_refunds_rec => l_pay_cure_refunds_rec
             ,x_cure_refund_header_id       => l_cure_refund_header_id);

     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'okl_pay_cure_refunds_pvt.CREATE_REFUND_HDR'
                                    ||l_return_status || 'refund_id' ||l_cure_refund_header_id);
             END IF;
           END IF;
          x_cure_refund_header_id :=l_cure_refund_header_id;
          x_return_status  :=l_return_status;
    END IF;

  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );




EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','CREATE_REFUND_HDR');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_refund_hdr;

PROCEDURE delete_refund_hdr
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS
l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'DELETE_REFUND_HDR';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;

BEGIN

      SAVEPOINT DELETE_REFUND_HDR;
       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.DELETE_REFUND_HDR');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.DELETE_REFUND_HDR(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_refund_header_id     => p_refund_header_id);

     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'success - delete refund batch');
             END IF;
           END IF;
          x_return_status  :=l_return_status;
    END IF;

  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO DELETE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','DELETE_REFUND_HDR');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


END delete_refund_hdr;

PROCEDURE update_refund_hdr
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS


l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'UPDATE_REFUND_HDR';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;
l_pay_cure_refunds_rec pay_cure_refunds_rec_type
                               :=p_pay_cure_refunds_rec;

BEGIN

       SAVEPOINT UPDATE_REFUND_HDR;

       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.UPDATE_REFUND_HDR');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.UPDATE_REFUND_HDR(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_pay_cure_refunds_rec => l_pay_cure_refunds_rec);


     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'okl_pay_cure_refunds_pvt.UPDATE_REFUND_HDR'
                                    ||l_return_status );
             END IF;
           END IF;
           x_return_status  :=l_return_status;
    END IF;

  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

 EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','UPDATE_REFUND_HDR');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END update_refund_hdr;

PROCEDURE submit_cure_refund_hdr
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS

l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'SUBMIT_CURE_REFUND_HDR';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;

BEGIN

      SAVEPOINT SUBMIT_CURE_REFUND_HDR;

       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.SUBMIT_CURE_REFUND_HDR');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.SUBMIT_CURE_REFUND_HDR(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_refund_header_id     => p_refund_header_id);

     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'success - changed status to ENETRED');
             END IF;
           END IF;
          x_return_status  :=l_return_status;
    END IF;

  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO SUBMIT_CURE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SUBMIT_CURE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO SUBMIT_CURE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','SUBMIT_CURE_REFUND_HDR');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END submit_cure_refund_hdr;

PROCEDURE  approve_cure_refunds
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               )
IS

l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'APPROVE_CURE_REFUNDS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;

BEGIN

      SAVEPOINT APPROVE_CURE_REFUNDS;
       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,

                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.SUBMIT_CURE_REFUNDS');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.APPROVE_CURE_REFUNDS(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_refund_header_id     => p_refund_header_id
           );

     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'success - CREATED cure refunds');
             END IF;
           END IF;
          x_return_status  :=l_return_status;
    END IF;


  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO APPROVE_CURE_REFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO APPROVE_CURE_REFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO APPROVE_CURE_REFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','APPROVE_CURE_REFUNDS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END  approve_cure_refunds;




PROCEDURE submit_cure_refunds
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_status            IN VARCHAR2
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2)
IS

l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'SUBMIT_CURE_REFUNDS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;

BEGIN

      SAVEPOINT SUBMIT_CURE_REFUNDS;
       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,

                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.SUBMIT_CURE_REFUNDS');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.SUBMIT_CURE_REFUNDS(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
             ,p_status               =>p_status
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_refund_header_id     => p_refund_header_id
           );

     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'success - CREATED cure refunds');
             END IF;
           END IF;
          x_return_status  :=l_return_status;
    END IF;


  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO SUBMIT_CURE_REFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SUBMIT_CURE_REFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO SUBMIT_CURE_REFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','SUBMIT_CURE_REFUNDS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END  SUBMIT_cure_refunds;


PROCEDURE create_refund_headers
             (  p_api_version             IN NUMBER
               ,p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit                  IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec    IN pay_cure_refunds_rec_type
               ,x_cure_refund_header_id   OUT NOCOPY  NUMBER
               ,x_return_status           OUT NOCOPY VARCHAR2
               ,x_msg_count               OUT NOCOPY NUMBER
               ,x_msg_data                OUT NOCOPY VARCHAR2
               )IS

l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_cure_refund_header_id okl_cure_refund_headers_b.cure_refund_header_id%type;
l_pay_cure_refunds_rec pay_cure_refunds_rec_type
                               :=p_pay_cure_refunds_rec;
l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_REFUND_headers';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;

BEGIN

      SAVEPOINT CREATE_REFUND_HEADERS;

       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.CREATE_REFUND_headers');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.CREATE_REFUND_headers(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_pay_cure_refunds_rec => l_pay_cure_refunds_rec
             ,x_cure_refund_header_id       => l_cure_refund_header_id);

     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'okl_pay_cure_refunds_pvt.CREATE_REFUND_headers'
                                    ||l_return_status || 'refund_id' ||l_cure_refund_header_id);
             END IF;
           END IF;
          x_cure_refund_header_id :=l_cure_refund_header_id;
          x_return_status  :=l_return_status;
    END IF;

  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );




EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','CREATE_REFUND_HEADERS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_refund_headers;


PROCEDURE UPDATE_REFUND_HEADERS
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS


l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'UPDATE_REFUND_HEADERS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;
l_pay_cure_refunds_rec pay_cure_refunds_rec_type
                               :=p_pay_cure_refunds_rec;

BEGIN

       SAVEPOINT UPDATE_REFUND_HEADERS;

       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.UPDATE_REFUND_HEADERS');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.UPDATE_REFUND_HEADERS(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_pay_cure_refunds_rec => l_pay_cure_refunds_rec);


     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'okl_pay_cure_refunds_pvt.UPDATE_REFUND_HEADERS'
                                    ||l_return_status );
             END IF;
           END IF;
           x_return_status  :=l_return_status;
    END IF;

  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

 EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','UPDATE_REFUND_HEADERS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END UPDATE_REFUND_HEADERS;

PROCEDURE CREATE_REFUND_DETAILS
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_tbl IN pay_cure_refunds_tbl_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS


l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_REFUND_DETAILS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;
l_pay_cure_refunds_tbl pay_cure_refunds_tbl_type
                               :=p_pay_cure_refunds_tbl;

BEGIN

       SAVEPOINT CREATE_REFUND_DETAILS;

       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.CREATE_REFUND_DETAILS');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.CREATE_REFUND_DETAILS(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_pay_cure_refunds_tbl => l_pay_cure_refunds_tbl);


     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'okl_pay_cure_refunds_pvt.CREATE_REFUND_DETAILS'
                                    ||l_return_status );
             END IF;
           END IF;
           x_return_status  :=l_return_status;
    END IF;

  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

 EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_REFUND_DETAILS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_REFUND_DETAILS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_REFUND_DETAILS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','CREATE_REFUND_DETAILS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END CREATE_REFUND_DETAILS;


PROCEDURE UPDATE_REFUND_DETAILS
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_tbl IN pay_cure_refunds_tbl_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS


l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'UPDATE_REFUND_DETAILS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;
l_pay_cure_refunds_tbl pay_cure_refunds_tbl_type
                               :=p_pay_cure_refunds_tbl;

BEGIN

       SAVEPOINT UPDATE_REFUND_DETAILS;

       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.UPDATE_REFUND_DETAILS');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.UPDATE_REFUND_DETAILS(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_pay_cure_refunds_tbl => l_pay_cure_refunds_tbl);


     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'okl_pay_cure_refunds_pvt.UPDATE_REFUND_DETAILS'
                                    ||l_return_status );
             END IF;
           END IF;
           x_return_status  :=l_return_status;
    END IF;

  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

 EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_REFUND_DETAILS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_REFUND_DETAILS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_REFUND_DETAILS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','UPDATE_REFUND_DETAILS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END UPDATE_REFUND_DETAILS;

PROCEDURE DELETE_REFUND_DETAILS
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_tbl IN pay_cure_refunds_tbl_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS


l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'DELETE_REFUND_DETAILS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;
l_pay_cure_refunds_tbl pay_cure_refunds_tbl_type
                               :=p_pay_cure_refunds_tbl;

BEGIN

       SAVEPOINT DELETE_REFUND_DETAILS;

       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                           	               p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling '||
                           'okl_pay_cure_refunds_pvt.DELETE_REFUND_DETAILS');
         END IF;
      END IF;

      l_return_status := FND_API.G_RET_STS_SUCCESS;

  	  okl_pay_cure_refunds_pvt.DELETE_REFUND_DETAILS(
              p_api_version		     => l_api_version
      	     ,p_init_msg_list	     => p_init_msg_list
             ,p_commit               => p_commit
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
	         ,x_msg_data	      	 => l_msg_data
             ,p_pay_cure_refunds_tbl => l_pay_cure_refunds_tbl);


     IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	      RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'okl_pay_cure_refunds_pvt.DELETE_REFUND_DETAILS'
                                    ||l_return_status );
             END IF;
           END IF;
           x_return_status  :=l_return_status;
    END IF;

  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

 EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_REFUND_DETAILS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_REFUND_DETAILS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO DELETE_REFUND_DETAILS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PUB','DELETE_REFUND_DETAILS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END DELETE_REFUND_DETAILS;


end OKL_PAY_CURE_REFUNDS_PUB;

/
