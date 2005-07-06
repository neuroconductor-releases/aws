C
C    Copyright (C) 2004 Weierstrass-Institut fuer 
C                       Angewandte Analysis und Stochastik (WIAS)
C
C    Author:  Joerg Polzehl
C
C  This program is free software; you can redistribute it and/or modify
C  it under the terms of the GNU General Public License as published by
C  the Free Software Foundation; either version 2 of the License, or
C  (at your option) any later version.
C
C  This program is distributed in the hope that it will be useful,
C  but WITHOUT ANY WARRANTY; without even the implied warranty of
C  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C  GNU General Public License for more details.
C
C  You should have received a copy of the GNU General Public License
C  along with this program; if not, write to the Free Software
C  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
C  USA.
C
C  The following routines are part of the aws package and contain  
C  FORTRAN 77 code needed in R functions aws, vaws, 
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C    location penalty for multivariate non-gridded aws
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      real*8 function lmkern(kern,dx,xi,xj,h2)
      implicit logical (a-z)
      external lkern
      integer kern,dx,i
      real*8 xi(dx),xj(dx),h2,z,zd,lkern
      z=0.d0
      do 1 i=1,dx
         zd=xi(i)-xj(i)
         z=z+zd*zd
	 if(z.gt.h2) goto 2
1     continue
      lmkern=lkern(kern,z/h2)
      goto 999
2     lmkern=0.d0
999   return
      end
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C
C   Local constant aws on a grid      
C
C   this is a reimplementation of the original aws procedure
C
C   should be slightly slower for non-Gaussian models (see function kldist)
C    
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C
C          Compute the Kullback-Leibler Distance
C
C          Model=1    Gaussian   
C          Model=2    Bernoulli   
C          Model=3    Poisson   
C          Model=4    Exponential   
C
C     computing dlog(theta) and dlog(1.d0-theta) outside the AWS-loops 
C     will reduces computational costs at the price of readability
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      real*8 function kldist(model,thi,thj,bi0)
      implicit logical (a-z)
      integer model
      real*8 thi,thj,z,thij,bi0,eta,tthi
      IF (model.eq.1) THEN
C        Gaussian
         z=thi-thj
         kldist=z*z
      ELSE IF (model.eq.2) THEN
C        Bernoulli
         kldist=0.d0
         eta=0.5d0/bi0
         thij=(1.d0-eta)*thj+eta*thi
         tthi=(1.d0-thi)
         IF (thi.gt.1.d-10) kldist=kldist+thi*dlog(thi/thij)
         IF (tthi.gt.1.d-10) kldist=kldist+tthi*dlog(tthi/(1.d0-thij))
      ELSE IF (model.eq.3) THEN
C        Poisson
         kldist=0.d0
         eta=0.5d0/bi0
         thij=(1.d0-eta)*thj+eta*thi
         IF (thi.gt.1.d-10) kldist=thi*dlog(thi/thij)-thi+thij
      ELSE IF (model.eq.4) THEN
C        Exponential
         kldist=thi/thj-1.d0-dlog(thi/thj)
      ELSE IF (model.eq.5) THEN
C        Exponential
         kldist=thi/thj-1.d0-dlog(thi/thj)
      ELSE
C        use Gaussian
         z=thi-thj
         kldist=z*z
      ENDIF
      RETURN
      END
      real*8 function kldist0(model,thi,thj)
      implicit logical (a-z)
      integer model
      real*8 thi,thj,z
      IF (model.eq.1) THEN
C        Gaussian
         z=thi-thj
         kldist0=z*z
      ELSE IF (model.eq.2) THEN
C        Bernoulli
         kldist0=thi*dlog(thi/thj)+(1.d0-thi)*dlog((1.d0-thi)/
     1           (1.d0-thj))
      ELSE IF (model.eq.3) THEN
C        Poisson
         kldist0=thi*dlog(thi/thj)-thi+thj
      ELSE IF (model.eq.4) THEN
C        Exponential
         kldist0=thi/thj-1.d0-dlog(thi/thj)
      ELSE
C        use Gaussian
         z=thi-thj
         kldist0=z*z
      ENDIF
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C
C          Compute Location Kernel (Compact support only, based on x^2
C                                   ignores scaling)
C
C          Kern=1     Uniform
C          Kern=2     Epanechnicov
C          Kern=3     Biweight
C          Kern=4     Triweight
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      real*8 function lkern(kern,xsq)
      implicit logical (a-z)
      integer kern
      real*8 xsq,z
      IF (xsq.ge.1) THEN
         lkern=0.d0
      ELSE IF (kern.eq.1) THEN
         lkern=1.d0
      ELSE IF (kern.eq.2) THEN
         lkern=1.d0-xsq
      ELSE IF (kern.eq.3) THEN
         z=1.d0-xsq
         lkern=z*z
      ELSE IF (kern.eq.4) THEN
         z=1.d0-xsq
         lkern=z*z*z
      ELSE
C        use Epanechnikov
         lkern=1.d0-xsq
      ENDIF
      RETURN 
      END   
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C        Compute truncated Exponential Kernel 
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      real*8 function skern(x,xmax)
      implicit logical (a-z)
      real*8 x,xmax
      IF (x.gt.xmax) THEN
         skern=0.d0
      ELSE
         skern=dexp(-x)
      ENDIF
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C   Perform one iteration in local constant three-variate aws (gridded)
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine caws(y,fix,n1,n2,n3,hakt,lambda,theta,bi,bi2,
     1                   bi0,ai,model,kern,spmax,wght)
C   
C   y        observed values of regression function
C   n1,n2,n3    design dimensions
C   hakt     actual bandwidth
C   lambda   lambda or lambda*sigma2 for Gaussian models
C   theta    estimates from last step   (input)
C   bi       \sum  Wi   (output)
C   ai       \sum  Wi Y     (output)
C   model    specifies the probablilistic model for the KL-Distance
C   kern     specifies the location kernel
C   spmax    specifies the truncation point of the stochastic kernel
C   wght     scaling factor for second and third dimension (larger values shrink)
C   
      implicit logical (a-z)
      external kldist,lkern
      real*8 kldist,lkern
      integer n1,n2,n3,model,kern
      logical aws,fix(1)
      real*8 y(1),theta(1),bi(1),bi0(1),ai(1),lambda,spmax,wght(2),
     1       bi2(1),hakt
      integer ih1,ih2,ih3,i1,i2,i3,j1,j2,j3,ja1,je1,ja2,je2,ja3,je3,
     1        iind,jind,jind3,jind2
      real*8 thetai,bii,sij,swj,swj2,swj0,swjy,z1,z2,z3,wj,hakt2,bii0
      hakt2=hakt*hakt
      ih1=hakt
      aws=lambda.lt.1d40
      DO i3=1,n3
         DO i2=1,n2
             DO i1=1,n1
	       iind=i1+(i2-1)*n1+(i3-1)*n1*n2
               IF (fix(iind)) CYCLE
C    nothing to do, final estimate is already fixed by control 
               thetai=theta(iind)
               bii=bi(iind)/lambda
C   scaling of sij outside the loop
               bii0=bi0(iind)
	       ih3=hakt/wght(2)
               ja3=max0(1,i3-ih3)
               je3=min0(n3,i3+ih3)
               swj=0.d0
	       swj2=0.d0
               swj0=0.d0
               swjy=0.d0
               DO j3=ja3,je3
                  z3=(i3-j3)*wght(2)
                  z3=z3*z3
                  ih2=dsqrt(hakt2-z3)/wght(1)
                  ja2=max0(1,i2-ih2)
                  je2=min0(n2,i2+ih2)
		  jind3=(j3-1)*n1*n2
                  DO j2=ja2,je2
                     z2=(i2-j2)*wght(1)
                     z2=z3+z2*z2
                     ih1=dsqrt(hakt2-z2)
                     ja1=max0(1,i1-ih1)
                     je1=min0(n1,i1+ih1)
		     jind2=jind3+(j2-1)*n1
                     DO j1=ja1,je1
C  first stochastic term
                        jind=j1+jind2
                        z1=(i1-j1)
                        wj=lkern(kern,(z1*z1+z2)/hakt2)
                        swj0=swj0+wj
                        IF (aws) THEN
                  sij=bii*kldist(model,thetai,theta(jind),bii0)
                           IF (sij.gt.spmax) CYCLE
                           wj=wj*exp(-sij)
                        END IF
                        swj=swj+wj
                        swj2=swj2+wj*wj
                        swjy=swjy+wj*y(jind)
                     END DO
                  END DO
               END DO
               ai(iind)=swjy
               bi(iind)=swj
               bi2(iind)=swj2
               bi0(iind)=swj0
            END DO
         END DO
      END DO
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C   Perform one iteration in local constant three-variate aws (gridded)
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine chaws(y,fix,si2,n1,n2,n3,hakt,lambda,theta,bi,bi2,
     1                 bi0,ai,model,kern,spmax,wght)
C   
C   y        observed values of regression function
C   n1,n2,n3    design dimensions
C   hakt     actual bandwidth
C   lambda   lambda or lambda*sigma2 for Gaussian models
C   theta    estimates from last step   (input)
C   bi       \sum  Wi   (output)
C   bi2      \sum  Wi^2*sigma2   (output)
C   ai       \sum  Wi Y     (output)
C   model    specifies the probablilistic model for the KL-Distance
C   kern     specifies the location kernel
C   spmax    specifies the truncation point of the stochastic kernel
C   wght     scaling factor for second and third dimension (larger values shrink)
C   
      implicit logical (a-z)
      external kldist,lkern
      real*8 kldist,lkern
      integer n1,n2,n3,model,kern
      logical aws,fix(1)
      real*8 y(1),theta(1),bi(1),bi0(1),ai(1),lambda,spmax,wght(2),
     1       bi2(1),hakt,si2(1),hakt2
      integer ih1,ih2,ih3,i1,i2,i3,j1,j2,j3,ja1,je1,ja2,je2,ja3,je3,
     1        iind,jind,jind3,jind2
      real*8 thetai,bii,sij,swj,swj2,swj0,swjy,z1,z2,z3,wj,wj0,bii0
      hakt2=hakt*hakt
      ih1=hakt
      aws=lambda.lt.1d40
      DO i3=1,n3
         DO i2=1,n2
             DO i1=1,n1
	       iind=i1+(i2-1)*n1+(i3-1)*n1*n2
               IF (fix(iind)) CYCLE
C    nothing to do, final estimate is already fixed by control 
               thetai=theta(iind)
               bii=bi(iind)/lambda
C   scaling of sij outside the loop
               bii0=bi0(iind)
	       ih3=hakt/wght(2)
               ja3=max0(1,i3-ih3)
               je3=min0(n3,i3+ih3)
               swj=0.d0
	       swj2=0.d0
               swj0=0.d0
               swjy=0.d0
               DO j3=ja3,je3
                  z3=(i3-j3)*wght(2)
                  z3=z3*z3
                  ih2=dsqrt(hakt2-z3)/wght(1)
                  ja2=max0(1,i2-ih2)
                  je2=min0(n2,i2+ih2)
		  jind3=(j3-1)*n1*n2
                  DO j2=ja2,je2
                     z2=(i2-j2)*wght(1)
                     z2=z3+z2*z2
                     ih1=dsqrt(hakt2-z2)
                     ja1=max0(1,i1-ih1)
                     je1=min0(n1,i1+ih1)
		     jind2=jind3+(j2-1)*n1
                     DO j1=ja1,je1
C  first stochastic term
                        jind=j1+jind2
                        z1=(i1-j1)
                        wj0=lkern(kern,(z1*z1+z2)/hakt2)
			wj=wj0*si2(jind)
                        swj0=swj0+wj
                        IF (aws) THEN
                   sij=bii*kldist(model,thetai,theta(jind),bii0)
                           IF (sij.gt.spmax) CYCLE
                           wj=wj*exp(-sij)
                        END IF
                        swj=swj+wj
                        swj2=swj2+wj*wj0
                        swjy=swjy+wj*y(jind)
                     END DO
                  END DO
               END DO
               ai(iind)=swjy
               bi(iind)=swj
               bi2(iind)=swj2
               bi0(iind)=swj0
            END DO
         END DO
      END DO
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C
C          Compute the Kullback-Leibler Distance (for vaws)
C
C          Model=1    Gaussian   
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      real*8 function vkldist(model,d,thi,thj,bi0,vw)
      implicit logical (a-z)
      integer model,d,i
      real*8 thi(d),thj(d),z,z0,bi0,vw(d)
C        Gaussian case only in the moment
         z=0.d0
	 DO i=1,d
            z0=thi(i)-thj(i)
	    z=z+z0*z0*vw(i)
	 END DO
         vkldist=z
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C   Perform one iteration in local constant three-variate aws (gridded)
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine vaws(y,fix,d,n1,n2,n3,ns,hakt,lambda,theta,bi,bi2,
     1                 bi0,ai,kern,spmax,wght,thetai,swjy,vw)
C   
C   y        observed values of regression function
C   n1,n2,n3    design dimensions
C   ns       length of sigma
C   hakt     actual bandwidth
C   lambda   lambda or lambda*sigma2 for Gaussian models
C   theta    estimates from last step   (input)
C   bi       \sum  Wi   (output)
C   bi2      \sum  Wi^2*sigma2   (output)
C   ai       \sum  Wi Y     (output)
C   model    specifies the probablilistic model for the KL-Distance
C   kern     specifies the location kernel
C   spmax    specifies the truncation point of the stochastic kernel
C   wght     scaling factor for second and third dimension (larger values shrink)
C   
      implicit logical (a-z)
      external vkldist,lkern
      real*8 vkldist,lkern
      integer d,n1,n2,n3,model,kern,ns
      logical aws,fix(1),hetero
      real*8 y(d,1),theta(d,1),bi(1),bi0(1),ai(d,1),lambda(1),spmax,
     1       wght(2),bi2(1),hakt,hakt2,thetai(d),swjy(d),vw(d)
      integer ih1,ih2,ih3,i1,i2,i3,j1,j2,j3,ja1,je1,ja2,je2,ja3,je3,
     1        iind,jind,jind3,jind2,k,indis
      real*8 bii,sij,swj,swj2,swj0,z1,z2,z3,wj,wj0,bii0
      model=1
      hakt2=hakt*hakt
      ih1=hakt
      aws=lambda(1).lt.1d40
      hetero=ns.gt.1
      indis=1
      DO i3=1,n3
         DO i2=1,n2
             DO i1=1,n1
	       iind=i1+(i2-1)*n1+(i3-1)*n1*n2
	       if(hetero) indis=iind
               IF (fix(iind)) CYCLE
C    nothing to do, final estimate is already fixed by control 
               bii=bi(iind)/lambda(indis)
C   scaling of sij outside the loop
               bii0=bi0(iind)
	       ih3=hakt/wght(2)
               ja3=max0(1,i3-ih3)
               je3=min0(n3,i3+ih3)
               DO k=1,d
                  thetai(k)=theta(k,iind)
		  swjy(k)=0.d0
	       END DO
               swj=0.d0
	       swj2=0.d0
               swj0=0.d0
               DO j3=ja3,je3
                  z3=(i3-j3)*wght(2)
                  z3=z3*z3
                  ih2=dsqrt(hakt2-z3)/wght(1)
                  ja2=max0(1,i2-ih2)
                  je2=min0(n2,i2+ih2)
		  jind3=(j3-1)*n1*n2
                  DO j2=ja2,je2
                     z2=(i2-j2)*wght(1)
                     z2=z3+z2*z2
                     ih1=dsqrt(hakt2-z2)
                     ja1=max0(1,i1-ih1)
                     je1=min0(n1,i1+ih1)
		     jind2=jind3+(j2-1)*n1
                     DO j1=ja1,je1
C  first stochastic term
                        jind=j1+jind2
                        z1=(i1-j1)
                        wj=lkern(kern,(z1*z1+z2)/hakt2)
                        swj0=swj0+wj
                        IF (aws) THEN
                        sij=bii*vkldist(model,d,thetai,theta(1,jind),
     1                                  bii0,vw)
                           IF (sij.gt.spmax) CYCLE
                           wj=wj*exp(-sij)
                        END IF
                        swj=swj+wj
                        swj2=swj2+wj*wj
			DO k=1,d
                           swjy(k)=swjy(k)+wj*y(k,jind)
			END DO
                     END DO
                  END DO
               END DO
	       DO k=1,d
                  ai(k,iind)=swjy(k)
	       END DO
               bi(iind)=swj
               bi2(iind)=swj2
               bi0(iind)=swj0
            END DO
         END DO
      END DO
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C   Perform one iteration in local constant three-variate aws (gridded)
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine vhaws(y,fix,si2,d,n1,n2,n3,hakt,lambda,theta,bi,bi2,
     1                 bi0,ai,kern,spmax,wght,thetai,swjy,vw)
C   
C   y        observed values of regression function
C   n1,n2,n3    design dimensions
C   hakt     actual bandwidth
C   lambda   lambda or lambda*sigma2 for Gaussian models
C   theta    estimates from last step   (input)
C   bi       \sum  Wi   (output)
C   bi2      \sum  Wi^2*sigma2   (output)
C   ai       \sum  Wi Y     (output)
C   model    specifies the probablilistic model for the KL-Distance
C   kern     specifies the location kernel
C   spmax    specifies the truncation point of the stochastic kernel
C   wght     scaling factor for second and third dimension (larger values shrink)
C   
      implicit logical (a-z)
      external vkldist,lkern
      real*8 vkldist,lkern
      integer d,n1,n2,n3,model,kern
      logical aws,fix(1)
      real*8 y(d,1),theta(d,1),bi(1),bi0(1),ai(d,1),lambda,spmax,
     1       wght(2),bi2(1),hakt,si2(1),hakt2,thetai(d),swjy(d),vw(d)
      integer ih1,ih2,ih3,i1,i2,i3,j1,j2,j3,ja1,je1,ja2,je2,ja3,je3,
     1        iind,jind,jind3,jind2,k
      real*8 bii,sij,swj,swj2,swj0,z1,z2,z3,wj,wj0,bii0,esij
      model=1
      hakt2=hakt*hakt
      ih1=hakt
      aws=lambda.lt.1d40
      DO i3=1,n3
         DO i2=1,n2
             DO i1=1,n1
	       iind=i1+(i2-1)*n1+(i3-1)*n1*n2
               IF (fix(iind)) CYCLE
C    nothing to do, final estimate is already fixed by control 
               bii=bi(iind)/lambda
C   scaling of sij outside the loop
               bii0=bi0(iind)
	       ih3=hakt/wght(2)
               ja3=max0(1,i3-ih3)
               je3=min0(n3,i3+ih3)
               swj=0.d0
	       swj2=0.d0
               swj0=0.d0
               DO k=1,d
                  thetai(k)=theta(k,iind)
		  swjy(k)=0.d0
	       END DO
               DO j3=ja3,je3
                  z3=(i3-j3)*wght(2)
                  z3=z3*z3
                  ih2=dsqrt(hakt2-z3)/wght(1)
                  ja2=max0(1,i2-ih2)
                  je2=min0(n2,i2+ih2)
		  jind3=(j3-1)*n1*n2
                  DO j2=ja2,je2
                     z2=(i2-j2)*wght(1)
                     z2=z3+z2*z2
                     ih1=dsqrt(hakt2-z2)
                     ja1=max0(1,i1-ih1)
                     je1=min0(n1,i1+ih1)
		     jind2=jind3+(j2-1)*n1
                     DO j1=ja1,je1
C  first stochastic term
                        jind=j1+jind2
                        z1=(i1-j1)
                        wj0=lkern(kern,(z1*z1+z2)/hakt2)
			wj=wj0*si2(jind)
                        swj0=swj0+wj
                        IF (aws) THEN
                        sij=bii*vkldist(model,d,thetai,theta(1,jind),
     1                                  bii0,vw)
                           IF (sij.gt.spmax) CYCLE
			   esij=exp(-sij)
                           wj=wj*esij
                           wj0=wj0*esij
                        END IF
                        swj=swj+wj
                        swj2=swj2+wj*wj0
			DO k=1,d
                           swjy(k)=swjy(k)+wj*y(k,jind)
			END DO
                     END DO
                  END DO
               END DO
	       DO k=1,d
                  ai(k,iind)=swjy(k)
	       END DO
               bi(iind)=swj
               bi2(iind)=swj2
               bi0(iind)=swj0
            END DO
         END DO
      END DO
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C   Perform one iteration in univariate local polynomial aws
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine cpawsuni(n,dp1,dp2,x,y,fix,theta,bi,bi0,
     1        ai,lam,h,kern,cb,dmat,thij,psix,psiy,bii,spmax)
C    
C     n          number of design points
C     dp1        number of parameters  (p+1)
C     dp2        number of components in bi  (2*p+1)
C     x          design points (ordered)
C     y          observed values at design points
C     theta      old estimates from last step (input)
C     bi         \sum \Psi^T Wi^(k-1) \Psi    (input)
C     si0        \sum \Psi^T Wi0 \Psi [1,]    (input)
C     bi0        \sum \Psi^T Wi0 \Psi    (input/output)
C     ai         \sum \Psi^T Wi^(k-1) Y       (input)
C     ai        \sum \Psi^T Wi^k Y           (output)
C     lam        lambda*sigma2            (stochastic penalty parameter)
C     h          actual bandwidth         (location penalty parameter)
C     cb         binomial coefficients     
C     dmat       working arrays  dp1 times dp1
C     thij                     vector for parameter differences
C     psix,psiy                working memory 
C     
      implicit logical (a-z)
      integer n,dp1,dp2,i,j,k,l,je,ja,nwij,kern 
      logical aws,fix(n)
      real*8 lkern,x(n),y(n),psix(dp2),psiy(dp1),theta(dp1,n),
     1 bi(dp2,n),ai(dp1,n),lam,spmax,dmat(dp1,dp1),bii(dp2),
     2 thij(dp1),cb(dp1,dp1),bi0(dp2,n),lambda,h,
     3 sij,wij,z,xij,ha,ha2,eps,xi,zj,thijl
      external lkern,skern
C     
C     in case of dp1==1  lawsuni should be preferred  (p=0)
C
      eps=1.e-10
      aws=lam.gt.1.d20
      DO i=1,n
C        loop over design points, initialization
         IF (fix(i)) CYCLE
C    nothing to do, final estimate is already fixed by control 
	 lambda=lam
         ha=h
         xi=x(i)
C     first search for ja and je
1099     DO j=i,1,-1
            IF (x(j).le.xi-ha) EXIT
            ja=j
         END DO
         DO j=i,n
            IF (x(j).gt.xi+ha) EXIT
            je=j
         END DO
         IF (je-ja-1.le.dp1) THEN
            ha=ha*1.25
C            not enough points in neighborhood to estimate parameters
C            increase ha
            goto 1099
         END IF
         ha2=ha*ha
8999     nwij=0
         IF (aws) THEN
C
C            prepare for computation of stochastic and extension penalty 
C
C    get (Psi W_i Psi^T) and (Psi \tilde{W}_i Psi^T) in dmat
C    expand Bi in dmat
            l=1
            DO j=1,dp1
               DO k=1,dp1
                  dmat(j,k)=bi(j+k-1,i)/lambda
	       END DO
            END DO
         END IF
         DO l=1,dp2
            bii(l)=0.d0
            bi0(l,i)=0.d0
            IF (l.gt.dp1) CYCLE
            ai(l,i)=0.d0
         END DO
C      if not enough points with positive weights (counted in nwij)
C      lambda will be increased 
C      (to reduce panalization by stochastic and influence term)
C
C             loop over local neighborhood
C
         DO j=ja,je
C
C              get location weights
C
            xij=(x(j)-x(i))
            wij=lkern(kern,xij*xij/ha2)
            z=1.d0
            DO k=1,dp2
               psix(k)=z
               IF (k.le.dp1) psiy(k)=z*y(j)
               z=z*xij
            END DO
            DO k=1,dp2
               bi0(k,i)=bi0(k,i)+wij*psix(k)
	    END DO
            IF (aws) THEN
C    now stochastic penalty for alpha=Inf
C    need translation of theta(l,j) to model centered in xi
               DO l=1,dp1
                 thij(l)=theta(l,j)
               END DO
               IF (dp1.gt.1) THEN
                  z=1.d0
                  zj=1.d0
                  DO l=2,dp1
                     z=-z*xij
                     DO k=1,dp1-l+1
                        thij(k)=thij(k)+cb(k+l-1,k)*z*theta(k+l-1,j)
                     END DO
                  END DO
               END IF
C     thij contains theta_{j} in the model centered at xi
C
C                 now get sij
C
	       DO l=1,dp1
                  thij(l)=theta(l,i)-thij(l)
               END DO
C
C   thats the difference between thetai and thetaij
C
               sij=0.0d0
               DO l=1,dp1
	          thijl=thij(l)
		  sij=sij+dmat(l,l)*thijl*thijl
		  IF (l.eq.dp1) CYCLE
                  DO k=l+1,dp1
                     sij=sij+2.d0*dmat(k,l)*thijl*thij(k)
                  END DO
               END DO
C
C     now we have everything to compute  w_{ij}
C       
               IF (sij.gt.spmax) CYCLE
               wij=wij*dexp(-sij)
            END IF
            IF (wij.gt.eps) nwij=nwij+1
C        now compute contributions to bi(i),bi0(i),ai(i)  
            DO k=1,dp2
               bii(k)=bii(k)+wij*psix(k)
               IF (k.le.dp1) ai(k,i)=ai(k,i)+wij*psiy(k)
            END DO    
         END DO
C    this was the j - loop
         IF (nwij.lt.dp1.and.aws) THEN
            lambda=lambda*1.25
C    increase lambda to weaken stochastic penalization
            goto 8999
	 END IF
	 DO k=1,dp2 
	    bi(k,i)=bii(k)
         END DO	 
      END DO      
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C   Perform one iteration in univariate local polynomial aws
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine cphawsun(n,dp1,dp2,x,y,fix,si2,theta,bi,si0,bi0,
     1   ai,lam,h,kern,cb,dmat,thij,psix,psiy,bii,spmax)
C    
C     n          number of design points
C     dp1        number of parameters  (p+1)
C     dp2        number of components in bi  (2*p+1)
C     x          design points (ordered)
C     y          observed values at design points
C     theta      old estimates from last step (input)
C     bi         \sum \Psi^T Wi^(k-1) \Psi    (input)
C     bin        \sum \Psi^T Wi^k \Psi        (output)
C     si0        \sum \Psi^T Wi0 \Psi [1,]    (input)
C     bi0        \sum \Psi^T Wi0 \Psi    (input/output)
C     ai         \sum \Psi^T Wi^(k-1) Y       (input)
C     ai        \sum \Psi^T Wi^k Y           (output)
C     lam        lambda*sigma2            (stochastic penalty parameter)
C     h          actual bandwidth         (location penalty parameter)
C     cb         binomial coefficients     
C     dmat,        working arrays  dp1 times dp1
C     thij                     vector for parameter differences
C     psix,psiy                working memory 
C     
C      implicit logical (a-z)
      integer n,dp1,dp2,i,j,k,l,je,ja,nwij,kern 
      logical aws,fix(n)
      real*8 lkern,skern,x(n),y(n),psix(dp2),psiy(dp1),theta(dp1,n),
     1 bi(dp2,n),bii(dp2),ai(dp1,n),lam,spmax,si2(n),dmat(dp1,dp1),
     2 thij(dp1),cb(dp1,dp1),bi0(dp2,n),lambda,h,si0(n),
     4 sij,wij,z,xij,ha,ha2,eps,xi,zj,wijs,thijl
      external lkern,skern
      eps=1.e-10
      aws=lam.gt.1.d20
      DO i=1,n
C        loop over design points, initialization
         IF (fix(i)) CYCLE
C    nothing to do, final estimate is already fixed by control 
	 lambda=lam
         ha=h
         xi=x(i)
C     first search for ja and je
1099     DO j=i,1,-1
            IF (x(j).le.xi-ha) EXIT
            ja=j
         END DO
         DO j=i,n
            IF (x(j).gt.xi+ha) EXIT
            je=j
         END DO
         IF (je-ja-1.le.dp1) THEN
            ha=ha*1.25
C            not enough points in neighborhood to estimate parameters
C            increase ha
            goto 1099
         END IF
         ha2=ha*ha
8999     nwij=0
          IF (aws) THEN
C
C            prepare for computation of stochastic and extension penalty 
C
C    get (Psi W_i Psi^T) and (Psi \tilde{W}_i Psi^T) in dmat 
C    expand Bi in dmat
           l=1
            DO j=1,dp1
               DO k=1,dp1
                  dmat(j,k)=bi(j+k-1,i)/lambda
	       END DO
            END DO
         END IF
         DO l=1,dp2
            bii(l)=0.d0
            bi0(l,i)=0.d0
            IF (l.gt.dp1) CYCLE
            ai(l,i)=0.d0
         END DO
C      if not enough points with positive weights (counted in nwij)
C      lambda will be increased 
C      (to reduce panalization by stochastic and influence term)
C
C             loop over local neighborhood
C
         DO j=ja,je
C
C              get location weights
C
            xij=(x(j)-x(i))
            wij=lkern(kern,xij*xij/ha2)*si2(j)
	    wijs=1.d0
            z=1.d0
            DO k=1,dp2
               psix(k)=z
               IF (k.le.dp1) psiy(k)=z*y(j)
               z=z*xij
            END DO
            DO k=1,dp2
               bi0(k,i)=bi0(k,i)+wij*psix(k)
            END DO    
            IF (aws) THEN
C    now stochastic penalty for alpha=Inf
C    need translation of theta(l,j) to model centered in xi
               DO l=1,dp1
                 thij(l)=theta(l,j)
               END DO
               IF (dp1.gt.1) THEN
                  z=1.d0
                  zj=1.d0
                  DO l=2,dp1
                     z=-z*xij
                     DO k=1,dp1-l+1
                        thij(k)=thij(k)+cb(k+l-1,k)*z*theta(k+l-1,j)
                     END DO
                  END DO
               END IF
C     thij contains theta_{j} in the model centered at xi
C
C                 now get sij
C
	       DO l=1,dp1
                  thij(l)=theta(l,i)-thij(l)
               END DO
C
C   thats the difference between thetai and thetaij
C
               sij=0.0d0
               DO l=1,dp1
	          thijl=thij(l)
		  sij=sij+dmat(l,l)*thijl*thijl
		  IF (l.eq.dp1) CYCLE
                  DO k=l+1,dp1
                     sij=sij+2.d0*dmat(k,l)*thijl*thij(k)
                  END DO
               END DO
C
C     now we have everything to compute  w_{ij}
C       
               IF (sij.gt.spmax) CYCLE
               wij=wij*skern(sij,spmax)
            END IF
            IF (wij.gt.eps) nwij=nwij+1
C        now compute contributions to bi(i),bi0(i),ai(i)  
            DO k=1,dp2
               bii(k)=bii(k)+wij*psix(k)
               IF (k.le.dp1) ai(k,i)=ai(k,i)+wij*psiy(k)
            END DO    
         END DO    
C    this was the j - loop
         IF (nwij.lt.dp1.and.aws) THEN
            lambda=lambda*1.25
C    increase lambda to weaken stochastic penalization
            goto 8999
	 END IF
	 DO k=1,dp2 
	    bi(k,i)=bii(k)
         END DO	 
      END DO      
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C   Perform one iteration in bivariate local polynomial aws (gridded) 
C
C   p > 0   only  !!!! 
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine cpawsbi(n1,n2,dp1,dp2,y,fix,theta,bi,bi0,ai,
     1    lam,h,kern,dmat,thij,psix,si,si0,siy,ind,wght,spmax)
C
C     n1         number of points in first dimension
C     n2         number of points in second dimension
C     dp1        number of parameters  (p+1)
C     dp2        number of components in bi  (1,6,15)
C     y          observed values at design points
C     theta      estimates from step (k-1)   (input)
C     bi         \sum \Psi^T Wi \Psi  from step (k-1)
C     bin        \sum \Psi^T Wi \Psi  (output)
C     bi0        \sum \Psi^T Wi0 \Psi  from step (k-1)
C     ai        \sum \Psi^T Wi Y     (output)
C     lam        lambda*sigma2            (stochastic penalty parameter)
C     h          actual bandwidth         (location penalty parameter)
C     dmat       working arrays  dp1 times dp1
C     thij               vector for parameter differences
C     psix                     working memory for Psij
C     si         working array  for \sum \Psi^T Wi \Psi
C     si0        working array  for \sum \Psi^T Wi0 \Psi
C     siy        working array  for \sum \Psi^T Wi Y 
C
      implicit logical (a-z)
      integer n1,n2,dp1,dp2,i1,i2,j1,j2,k,l,info,je1,ja1,je2,ja2,
     1        j,ih1,ih2,ind(dp1,dp1),m,kern
      logical aws,fix(n1,n2)
      real*8 bi(dp2,n1,n2),bi0(dp2,n1,n2),lkern,
     1       ai(dp1,n1,n2),wght,theta(dp1,n1,n2),siy(dp1),
     2       dmat(dp1,dp1),thij(dp1),spmax,y(n1,n2),h,lam,
     3       psix(dp2),si(dp2),si0(dp2),sii,wijy,d,z11,z12,z22,ha2,
     4       lambda,wij,s0i,z1,z2,thijl
      external lkern
C     
C     in case of dp1==1  lawsbi should be called  (p=0)
C
      ha2=h*h
      ih1=h
      aws=lam.lt.1.d20
      DO i1=1,n1
         DO i2=1,n2
	    IF (fix(i1,i2)) CYCLE
C    nothing to do, estimate in (i1,i2) is already fixed by control
            lambda=lam
C  first fill si and siy with 0's
C  fields are used to sum components of ai, bin and bi0
8999        DO j=1,dp2
               si(j)=0.d0
               si0(j)=0.d0
               IF (j.le.dp1) siy(j)=0.d0
            END DO
            IF (aws) THEN
               DO j=1,dp1
                  DO k=1,dp1
                     m=ind(j,k)
                     dmat(j,k)=bi(m,i1,i2)/lambda
                  END DO
               END DO
               s0i=bi0(1,i1,i2)
               sii=bi(1,i1,i2)
            END IF
C
C     Prepare for loop over j's
C
            ja1=max0(1,i1-ih1)
            je1=min0(n1,i1+ih1)
            DO j1=ja1,je1
               z1=(i1-j1)
               z11=z1*z1
               ih2=dsqrt(ha2-z11)/wght
               ja2=max0(1,i2-ih2)
               je2=min0(n2,i2+ih2)
               DO j2=ja2,je2
                  z2=(i2-j2)*wght
                  z22=z2*z2
                  z12=z1*z2
C          first compute location part
                  wij=lkern(kern,(z11+z22)/ha2)
                  si0(1)=si0(1)+wij
                  si0(2)=si0(2)-z1*wij
                  si0(3)=si0(3)-z2*wij
                  si0(4)=si0(4)+z11*wij
                  si0(5)=si0(5)+z12*wij
                  si0(6)=si0(6)+z22*wij
                  IF (dp1.gt.3) THEN
                     si0(7)=si0(7)-z11*z1*wij
                     si0(8)=si0(8)-z11*z2*wij
                     si0(9)=si0(9)-z1*z22*wij
                     si0(10)=si0(10)-z2*z22*wij
                     si0(11)=si0(11)+z11*z11*wij
                     si0(12)=si0(12)+z11*z12*wij
                     si0(13)=si0(13)+z11*z22*wij
                     si0(14)=si0(14)+z12*z22*wij
                     si0(15)=si0(15)+z22*z22*wij
		  END IF
C          this is the location penalty, now fill si0
                  IF (aws) THEN 
C          now fill psix 
C           now translate thetaj into model centered in xi
C
                     thij(1)=theta(1,j1,j2)
                     thij(2)=theta(2,j1,j2)
                     thij(3)=theta(3,j1,j2)
                     thij(1)=thij(1)+thij(2)*z1+thij(3)*z2
                     IF (dp1.gt.3) THEN
                        thij(4)=theta(4,j1,j2)
                        thij(5)=theta(5,j1,j2)
                        thij(6)=theta(6,j1,j2)
                        thij(1)=thij(1)+thij(4)*z11+
     +                           thij(5)*z12+thij(6)*z22
                        thij(2)=thij(2)+thij(5)*z2+2.d0*thij(4)*z1
                        thij(3)=thij(3)+thij(5)*z1+2.d0*thij(6)*z2
		     END IF
C  
C           get difference of thetas
C
                     DO l=1,dp1
                        thij(l)=theta(l,i1,i2)-thij(l)
                     END DO
C
C           get stochastic penalty
C
                     d=0.d0
                     DO l=1,dp1
		        thijl=thij(l)
		        d=d+dmat(l,l)*thijl*thijl
			IF(l.eq.dp1) CYCLE
                        DO k=l+1,dp1
                           d=d+2.d0*dmat(k,l)*thijl*thij(k)
                        END DO
                     END DO
C
C           now compute weights 
C           stochastic and extension penalty can be added because kernel is exp
C
                     IF (d.gt.spmax) CYCLE
                     wij=wij*dexp(-d)
	          END IF
C           now compute contributions to bi(i),ai(i)  
                  wijy=y(j1,j2)*wij
                  si(1)=si(1)+wij
                  si(2)=si(2)-z1*wij
                  si(3)=si(3)-z2*wij
                  si(4)=si(4)+z11*wij
                  si(5)=si(5)+z12*wij
                  si(6)=si(6)+z22*wij
                  siy(1)=siy(1)+wijy
                  siy(2)=siy(2)-z1*wijy
                  siy(3)=siy(3)-z2*wijy
        	  IF (dp1.le.3) CYCLE
                  si(7)=si(7)-z11*z1*wij
                  si(8)=si(8)-z11*z2*wij
                  si(9)=si(9)-z1*z22*wij
                  si(10)=si(10)-z2*z22*wij
                  si(11)=si(11)+z11*z11*wij
                  si(12)=si(12)+z11*z12*wij
                  si(13)=si(13)+z11*z22*wij
                  si(14)=si(14)+z12*z22*wij
                  si(15)=si(15)+z22*z22*wij
                  siy(4)=siy(4)+z11*wijy
                  siy(5)=siy(5)+z12*wijy
		  siy(6)=siy(6)+z22*wijy
               END DO
            END DO
C        prepare matrix to test for singularity of Bi 
C        this should be changed to SVD at some point
            DO k=1,dp1
               DO j=1,dp1
                  IF (j.gt.k) THEN
                     dmat(j,k)=0.d0
                  ELSE
                     dmat(j,k)=si(ind(j,k))
                  ENDIF
               END DO
            END DO
C
C     compute choleski decomposition
C
            call invers(dmat,dp1,info)
            IF (info.gt.0) THEN
C
C          if singular relax stochastic and extension penalty 
C
               lambda=1.5*lambda
               goto 8999
            END IF
C     
C     now fill ai, bi and bi0
C
            DO j=1,dp1
               ai(j,i1,i2)=siy(j)
            END DO
            DO j=1,dp2
               bi(j,i1,i2)=si(j)
               bi0(j,i1,i2)=si0(j)
            END DO
         END DO     
      END DO     
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C   Perform one iteration in bivariate local polynomial aws (gridded) 
C
C   p > 0   only  !!!! 
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine cphawsbi(n1,n2,dp1,dp2,y,fix,si2,theta,bi,bi0,ai,
     1    lam,h,kern,dmat,thij,psix,si,si0,siy,ind,wght,spmax)
C
C
C     n1         number of points in first dimension
C     n2         number of points in second dimension
C     dp1        number of parameters  (p+1)
C     dp2        number of components in bi  (1,6,15)
C     y          observed values at design points
C     theta      estimates from step (k-1)   (input)
C     bi         \sum \Psi^T Wi \Psi  from step (k-1)
C     bi0        \sum \Psi^T Wi0 \Psi  from step (k-1)
C     ai        \sum \Psi^T Wi Y     (output)
C     lam        lambda*sigma2            (stochastic penalty parameter)
C     h          actual bandwidth         (location penalty parameter)
C     dmat       working arrays  dp1 times dp1
C     thij               vector for parameter differences
C     psix                     working memory for Psij
C     si         working array  for \sum \Psi^T Wi \Psi
C     si0        working array  for \sum \Psi^T Wi0 \Psi
C     siy        working array  for \sum \Psi^T Wi Y 
C
      implicit logical (a-z)
      integer n1,n2,dp1,dp2,i1,i2,j1,j2,k,l,info,je1,ja1,je2,ja2,
     1        j,ih1,ih2,ind(dp1,dp1),m,kern
      logical aws,fix(n1,n2)
      real*8 bi(dp2,n1,n2),bi0(dp2,n1,n2),lkern,skern,ai(dp1,n1,n2),
     1       wght,si2(n1,n2),theta(dp1,n1,n2),dmat(dp1,dp1),siy(dp1),
     2       thij(dp1),spmax,y(n1,n2),lam,psix(dp2),si(dp2),si0(dp2),
     3       sii,wijy,d,z11,z12,z22,ha2,h,lambda,wij,s0i,z1,z2,thijl
      external lkern,skern
C     
C     in case of dp1==1  lawsbi should be called  (p=0)
C
      ha2=h*h
      ih1=h
      aws=lam.lt.1.d20
      DO i1=1,n1
         DO i2=1,n2
	    IF (fix(i1,i2)) CYCLE
C    nothing to do, estimate in (i1,i2) is already fixed by control
            lambda=lam
C  first fill si and siy with 0's
C  fields are used to sum components of ai, bi and bi0
8999        DO j=1,dp2
               si(j)=0.d0
               si0(j)=0.d0
               IF (j.le.dp1) siy(j)=0.d0
            END DO
            IF (aws) THEN
               DO j=1,dp1
                  DO k=1,dp1
                     m=ind(j,k)
                     dmat(j,k)=bi(m,i1,i2)
                  END DO
               END DO
               s0i=bi0(1,i1,i2)
               sii=bi(1,i1,i2)
            END IF
C
C     Prepare for loop over j's
C
            ja1=max0(1,i1-ih1)
            je1=min0(n1,i1+ih1)
            DO j1=ja1,je1
               z1=(i1-j1)
               z11=z1*z1
               ih2=dsqrt(ha2-z11)/wght
               ja2=max0(1,i2-ih2)
               je2=min0(n2,i2+ih2)
               DO j2=ja2,je2
                  z2=(i2-j2)*wght
                  z22=z2*z2
                  z12=z1*z2
C          first compute location part
                  wij=lkern(kern,(z11+z22)/ha2)*si2(j1,j2)
                  si0(1)=si0(1)+wij
                  si0(2)=si0(2)-z1*wij
                  si0(3)=si0(3)-z2*wij
                  si0(4)=si0(4)+z11*wij
                  si0(5)=si0(5)+z12*wij
                  si0(6)=si0(6)+z22*wij
                  IF (dp1.gt.3) THEN
                     si0(7)=si0(7)-z11*z1*wij
                     si0(8)=si0(8)-z11*z2*wij
                     si0(9)=si0(9)-z1*z22*wij
                     si0(10)=si0(10)-z2*z22*wij
                     si0(11)=si0(11)+z11*z11*wij
                     si0(12)=si0(12)+z11*z12*wij
                     si0(13)=si0(13)+z11*z22*wij
                     si0(14)=si0(14)+z12*z22*wij
                     si0(15)=si0(15)+z22*z22*wij
		  END IF
C          this is the location penalty, now fill si0
                  IF (aws) THEN 
C          now fill psix 
C           now translate thetaj into model centered in xi
C
                     thij(1)=theta(1,j1,j2)
                     thij(2)=theta(2,j1,j2)
                     thij(3)=theta(3,j1,j2)
                     thij(1)=thij(1)+thij(2)*z1+thij(3)*z2
                     IF (dp1.gt.3) THEN
                        thij(4)=theta(4,j1,j2)
                        thij(5)=theta(5,j1,j2)
                        thij(6)=theta(6,j1,j2)
                        thij(1)=thij(1)+thij(4)*z11+
     +                           thij(5)*z12+thij(6)*z22
                        thij(2)=thij(2)+thij(5)*z2+2.d0*thij(4)*z1
                        thij(3)=thij(3)+thij(5)*z1+2.d0*thij(6)*z2
		     END IF
C  
C           get difference of thetas
C
                     DO l=1,dp1
                        thij(l)=theta(l,i1,i2)-thij(l)
                     END DO
C
C           get stochastic penalty
C
                     d=0.d0
                     DO l=1,dp1
		        thijl=thij(l)
		        d=d+dmat(l,l)*thijl*thijl
			IF(l.eq.dp1) CYCLE
                        DO k=l+1,dp1
                           d=d+2.d0*dmat(k,l)*thijl*thij(k)
                        END DO
                     END DO
C
C           now compute weights 
C           stochastic and extension penalty can be added because kernel is exp
C
                     wij=wij*skern(d/lambda,spmax)
C           now compute contributions to bi(i),ai(i)  
                     wijy=y(j1,j2)*wij
                     si(1)=si(1)+wij
                     si(2)=si(2)-z1*wij
                     si(3)=si(3)-z2*wij
                     si(4)=si(4)+z11*wij
                     si(5)=si(5)+z12*wij
                     si(6)=si(6)+z22*wij
                     siy(1)=siy(1)+wijy
                     siy(2)=siy(2)-z1*wijy
                     siy(3)=siy(3)-z2*wijy
                     IF (dp1.le.3) CYCLE
                     si(7)=si(7)-z11*z1*wij
                     si(8)=si(8)-z11*z2*wij
                     si(9)=si(9)-z1*z22*wij
                     si(10)=si(10)-z2*z22*wij
                     si(11)=si(11)+z11*z11*wij
                     si(12)=si(12)+z11*z12*wij
                     si(13)=si(13)+z11*z22*wij
                     si(14)=si(14)+z12*z22*wij
                     si(15)=si(15)+z22*z22*wij
                     siy(4)=siy(4)+z11*wijy
                     siy(5)=siy(5)+z12*wijy
		     siy(6)=siy(6)+z22*wijy
	          END IF
               END DO
            END DO
C        prepare matrix to test for singularity of Bi 
C        this should be changed to SVD at some point
            DO k=1,dp1
               DO j=1,dp1
                  IF (j.gt.k) THEN
                     dmat(j,k)=0.d0
                  ELSE
                     dmat(j,k)=si(ind(j,k))
                  ENDIF
               END DO
            END DO
C
C     compute choleski decomposition
C
            call invers(dmat,dp1,info)
            IF (info.gt.0) THEN
C
C          if singular relax stochastic and extension penalty 
C
               lambda=1.5*lambda
               goto 8999
            END IF
C     
C     now fill ai, bin and bi0
C
            DO j=1,dp1
               ai(j,i1,i2)=siy(j)
            END DO
            DO j=1,dp2
               bi(j,i1,i2)=si(j)
               bi0(j,i1,i2)=si0(j)
            END DO
         END DO     
      END DO     
      RETURN
      END
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C      Generate estimates from ai and bi (univariate polynomial aws)
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine mpawsuni(n,dp1,dp2,ai,bi,theta,dmat)
C    
C     n          number of design points
C     dp1        number of parameters  (p+1)
C     dp2        number of components in bi  (2*p+1)
C     dpm        number of components in di  (dp1+1)*dp1/2
C     ai         \sum \Psi^T Wi^k Y       
C     bi         \sum \Psi^T Wi^k \Psi
C     di         inverse of bi     
C     di0         inverse of bi0     
C     theta      new parameter estimate
C     dmat       working array
C
C      implicit logical(a-z)
      integer n,dp1,dp2
      real*8 ai(dp1,n),bi(dp2,n),theta(dp1,n),dmat(dp1,dp1)
      integer i,j,k,info
      real*8 d
      DO i=1,n
         DO j=1,dp1
            DO k=1,dp1
               IF (j.gt.k) then 
                  dmat(j,k)=0.0d0
               ELSE
                  dmat(j,k)=bi(j+k-1,i)
               END IF
            END DO
	 END DO
         call invers(dmat,dp1,info)
         IF (info.ne.0) CYCLE 
C      now dmat contains inverse of B_i 
C      now calculate theta as B_i^{-1} A_i
         DO j=1,dp1
            d=0.0d0
            DO k=1,dp1
               d=d+dmat(j,k)*ai(k,i)  
            END DO
            theta(j,i)=d
         END DO
C     just keep the old estimate if info > 0
      END DO
      RETURN
      END      
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C      Generate estimates from ai and bi (bivariate case)
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine mpawsbi(n,dp1,dp2,ai,bi,theta,dmat,ind)
C    
C     n          number of design points
C     dp1        number of parameters  (p+1)
C     dp2        number of components in bi  (1,6,15)
C     ai         \sum \Psi^T Wi^k Y       
C     bi         \sum \Psi^T Wi^k \Psi    
C     theta      new parameter estimate
C     dmat       working arrays
C
C      implicit logical (a-z)
      integer n,dp1,dp2
      real*8 ai(dp1,n),bi(dp2,n),theta(dp1,n),dmat(dp1,dp1)
      integer i,j,k,info,ind(dp1,dp1)
      real*8 d
      DO i=1,n
         DO k=1,dp1
            DO j=1,dp1
               IF (j.gt.k) then
                  dmat(j,k)=0.d0
               ELSE
                  dmat(j,k)=bi(ind(j,k),i)
               END IF
            END DO
	 END DO
         call invers(dmat,dp1,info)
         IF (info.gt.0) CYCLE  
C     just keep the old estimate
C     now dmat contains inverse of B_i 
C     now calculate theta as B_i^{-1} A_i
         DO j=1,dp1
            d=0.0d0
            DO k=1,dp1
               d=d+dmat(j,k)*ai(k,i)  
            END DO
            theta(j,i)=d
         END DO
      END DO
      RETURN
      END      
c
c     invers computes the inverse of a certain
c     double precision symmetric positive definite matrix (see below)
c     
c     this code is based on choleski decomposition and
c     integrates code from linpack (dpofa.f and dpodi.f, version of 08/14/78 .
c     cleve moler, university of new mexico, argonne national lab.)
c     and BLAS
C
c     on entry
c
c        a       double precision(n, n)
c
c        n       integer
c                the order of the matrix  a .
c
c
c     on return
c
c        a       invers produces the upper half of inverse(a) .
c
c     subroutines and functions
c
c     fortran dsqrt
c
      subroutine invers(a, n, info)
      integer n,info
      double precision a(n,n)
c
c     internal variables
c
      double precision ddot,t
      double precision s
      integer j,jm1,k,l,i,kp1,im1
c     begin block with ...exits to 940 if singular (info.ne.0)
c
c
      DO j = 1, n
         info = j
         s = 0.0d0
         jm1 = j - 1
         IF (jm1 .ge. 1) THEN
            DO k = 1, jm1
               ddot=0.0d0
               DO l=1,k-1
                  ddot=ddot+a(l,k)*a(l,j)
               END DO           
               t = a(k,j) - ddot
               t = t/a(k,k)
               a(k,j) = t
               s = s + t*t
            END DO
	 END IF
         s = a(j,j) - s
c     .....exit
         IF (s .le. 1.d-100) RETURN
         a(j,j) = dsqrt(s)
      END DO
      info = 0
c
c     now we have the choeski decomposition in a     
c
c     next code from dpodi to compute inverse
c
      DO k = 1, n
         a(k,k) = 1.0d0/a(k,k)
         t = -a(k,k)
         DO l=1,k-1
            a(l,k)=t*a(l,k)
         END DO          
         kp1 = k + 1
         IF (n .ge. kp1) THEN
            DO j = kp1, n
               t = a(k,j)
               a(k,j) = 0.0d0
               DO l=1,k
                  a(l,j)=a(l,j)+t*a(l,k)
               END DO       
            END DO
         END IF
      END DO
c
c        form  inverse(r) * trans(inverse(r))
c
      DO j = 1, n
         jm1 = j - 1
         IF (jm1 .ge. 1) THEN
            DO k = 1, jm1
               t = a(k,j)
               DO l=1,k
                  a(l,k)=a(l,k)+t*a(l,j)
               END DO       
            END DO
	 END IF
         t = a(j,j)
         DO l=1,j
            a(l,j)=t*a(l,j)
         END DO          
      END DO
c
c     now fill lower triangle       
c  
      DO i=1,n
         im1 = i-1
         DO j=1,im1
            a(i,j) = a(j,i)
         END DO
      END DO
      RETURN
      END
