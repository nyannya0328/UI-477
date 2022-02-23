//
//  Home.swift
//  UI-477
//
//  Created by nyannyan0328 on 2022/02/23.
//

import SwiftUI
import AVFoundation

struct Home: View {
    
    @State var currentCoverImage : UIImage?
    
    @State var progress : CGFloat = 0
    
    @State var url : URL = URL(fileURLWithPath: Bundle.main.path(forResource: "Mountains - 59291", ofType: ".mp4") ?? "")
    var body: some View {
        VStack{
            
            
            VStack{
                HStack{
                   
                    Button {
                        
                    } label: {
                        
                        
                        Image(systemName: "chevron.left")
                            .font(.title2)
                        
                    }
                    
                    Spacer()
                    
                    
                    NavigationLink("Done"){
                        
                        if let currentCoverImage = currentCoverImage {
                            
                            
                            Image(uiImage: currentCoverImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .cornerRadius(15)
                        }
                        
                        
                    }

                    
                    
                }
                .overlay(Text("Done").font(.title))
                .padding([.horizontal,.bottom])
                Divider()
                    .background(.black.opacity(0.3))
                
                
                
            }
            .frame(maxHeight:.infinity,alignment: .top)
            
            
            GeometryReader{proxy in
                
                let size = proxy.size
                
                ZStack{
                    
                    
                    PreviewPlayer(url: $url, progress: $progress)
                        .cornerRadius(10)
                    
                    
             
                }
                .frame(width: size.width, height: size.height)
                
                
            }
            .frame(width: 200, height: 300)
            
            
            
            Text("To select a cover image chose a from\nyour video or an image from your camera roll.")
                .font(.callout.weight(.semibold))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top,20)
            
            let size = CGSize(width:200, height: 200)
            
            VideoCoverScroller(url: $url, progress: $progress,imageSize: size,coverImage: $currentCoverImage)
                .padding(.top,50)
                .padding(.horizontal,15)
            
            
            
            Button {
                
            } label: {
                
                
                Label {
                    
                    Text("Add to From Camera Roll")
                    
                } icon: {
                    
                    Image(systemName: "plus")
                }

            }
            .foregroundColor(.black)
            .padding(.vertical)


            
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct VideoCoverScroller : View{
    
    
    @Binding var url : URL
    
    @Binding var progress : CGFloat
    
    @State var imageSequence : [UIImage]?
    
    
    @State var offset : CGFloat = 0
    
    @GestureState var isDragging : Bool = false
    
    var imageSize : CGSize
    
    @Binding var coverImage : UIImage?
    
    var body: some View{
        
    
        GeometryReader{proxy in
            
            
            let size = proxy.size
            
            HStack(spacing:0){
                
                
                if let imageSequence = imageSequence {
                    
                    
                    ForEach(imageSequence,id:\.self){index in
                        
                        GeometryReader{proxy in
                            
                            let subSize = proxy.size
                            
                            
                            Image(uiImage: index)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width:subSize.width , height: subSize.height)
                                .clipped()
                        }
                        
                        .frame(height: size.height)
                    }
                    
                    
                    
                    
                }
                
                
                
                
            }
            .cornerRadius(2)
            .overlay(alignment: .leading, content: {
                
              
                
                ZStack(alignment: .leading) {
                    
                    Color.black.opacity(0.3)
                        .frame(height: size.height)
                    
                    
                    PreviewPlayer(url: $url, progress: $progress)
                        .frame(width: 35, height: 60)
                        .cornerRadius(10)
                        .background(
                        
                        
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.white,lineWidth: 3)
                            .padding(-3)
                        
                        )
                    
                        .background(
                        
                        
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.black.opacity(0.25))
                            .padding(-4)
                        
                        )
                        .offset(x: offset)
                        .gesture(
                        
                            DragGesture().updating($isDragging, body: { _, out, _ in
                                out = true
                            })
                            .onChanged({ value in
                                
                                
                                var translation = (isDragging ? value.location.x - 17.5 : 0)
                                
                                translation = (translation > 0 ? translation : 0)
                                
                                translation = (translation > size.width - 35 ? size.width - 35 : translation)
                                
                                offset = translation
                                
                                self.progress = (translation / (size.width - 35))
                            })
                            .onChanged({ _ in
                                retriveCoverImageAt(progress: progress, size: size) { image in
                                    
                                    
                                
                                    self.coverImage = image
                                }
                                
                                
                            })
                        
                        )
                }
                
                
            })
            .onAppear {
                if imageSequence == nil{
                    
                    generateImageSequence()
                }
                
            }
            .onChange(of: url) { newValue in
                
                progress = 0
                offset = .zero
                coverImage = nil
                imageSequence = nil
                
                generateImageSequence()
                
                retriveCoverImageAt(progress: progress, size: imageSize) { image in
                    
                    self.coverImage = image
                }
                
            }
          
           
        }
        .frame(height:50)
        
    }
    
    func generateImageSequence(){
        
        
        
        let parts = (vieoDulation() / 10)
        
        (1..<9).forEach { index in
            
            
            let progress = (CGFloat(index) * parts / vieoDulation())
            
            retriveCoverImageAt(progress: progress, size: CGSize(width: 0, height: 0)) { image in
                
                
                if imageSequence == nil{imageSequence = []}
                
                imageSequence?.append(image)
            }
            
        }
        
        
    }
    
    func retriveCoverImageAt(progress : CGFloat,size : CGSize,comeption : @escaping(UIImage) ->()){
        
        
        DispatchQueue.global(qos: .userInteractive).async{
            
            
            let asset = AVAsset(url: url)
            
            let generator = AVAssetImageGenerator(asset: asset)
            
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = size
            
            
            let time = CMTime(seconds: progress * vieoDulation(), preferredTimescale: 600)
            
            do{
                
                let image = try generator.copyCGImage(at: time, actualTime: nil)
                
                let cover = UIImage(cgImage: image)
                
                
                DispatchQueue.main.async {
                    
                    
                    comeption(cover)
                }
                
                
                
            }
            catch{
                
                print(error.localizedDescription)
            }
            
            
        }
        
        
        
    }
    
    func vieoDulation()->Double{
        
        let asset = AVAsset(url: url)
        return asset.duration.seconds
        
    }
}


