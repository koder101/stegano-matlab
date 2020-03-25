classdef algo < handle
    properties
        SourceFile
        SourceImage
        TextImage
        Psize
        Alpha
        Sy
        Uw
        Vw
        I_1
        WatermarkedImage
    end
    methods (Access = public)
        function initializeSource(this, SourceFile)
            this.SourceFile = SourceFile;
            this.SourceImage = imread( this.SourceFile);
            
            this.SourceImage = rgb2gray(this.SourceImage);
            
            [LL1,~,~,~] = dwt2(this.SourceImage,'haar');
            [LL2,~,~,~] = dwt2(LL1,'haar');
            this.Psize = size(LL2);
        end
                
        function text2Img(this, TextImage)
			this.TextImage = rgb2gray(Other_MEM_Text2Im(TextImage,20, 10,[1 0 0]));
			this.TextImage = imresize(this.TextImage, this.Psize);
		end
		
        function embed(this, Alpha)
            this.Alpha = Alpha;
            [LL1,HL1,LH1,HH1] = dwt2(this.SourceImage,'haar');
            [LL2,HL2,LH2,HH2] = dwt2(LL1,'haar');
            [Uy,this.Sy,Vy] = svd(LL2);
            [this.Uw,Sw,this.Vw] = svd(double(this.TextImage));
            Smark = this.Sy + Alpha*Sw;
            LL2_1 = Uy*Smark*Vy';
            LL1_1 = idwt2(LL2_1,HL2,LH2,HH2,'haar');
            
            % size(cA) = size(cH) = size(cV) = size(cD) must be same for idwt2
            LL1_1 = imresize(LL1_1,size(HL1));
            
            this.I_1 = idwt2(LL1_1,HL1,LH1,HH1,'haar');
            this.WatermarkedImage = uint8(this.I_1);
        end
        
        function ExtractedImage = extract(this)
            [LL1_wmv,~,~,~] = dwt2(this.I_1,'haar');
            [LL2_wmv,~,~,~] = dwt2(LL1_wmv,'haar');
            [~,Sy_wmv,~] = svd(LL2_wmv);
            Swrec = (Sy_wmv - this.Sy)/this.Alpha;
            WMy = this.Uw*Swrec*this.Vw';    
            ExtractedImage = uint8(WMy);
        end
    end
    methods(Access = public)
        function this = algo
        end
    end
end