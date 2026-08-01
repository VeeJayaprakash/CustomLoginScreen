//
//  ContentView.swift
//  CustomLogin
//
//  Created by Vijendran  on 7/29/26.
//

import SwiftUI

struct LoginView2: View {
    
    @State var email:String = ""
    @State var password:String = ""
    
    @FocusState var emailFocused:Bool
    @FocusState var passwordFocused:Bool
    @State var loginViewHeight:Double = 0
    @State var keyboarHeight:Double = 0
    
    var body: some View {
        
        ZStack {
            GeometryReader { proxy in
                
                let  topSpacerHeight:Double = keyboarHeight == 0 ? (proxy.size.height - loginViewHeight) / 2 : (keyboarHeight - loginViewHeight) / 2
                
                ScrollView {
                    Spacer(minLength: topSpacerHeight)
                    LoginContentView
                        .padding()
                        .overlay {
                            GeometryReader { innerProxy in
                                Color.clear.onAppear{
                                    loginViewHeight = innerProxy.size.height
                                }
                            }
                        }
                }
            }
            .ignoresSafeArea(edges: .top)
            .ignoresSafeArea(edges: .bottom)
            
            GeometryReader { proxy in
                Color(.clear).onGeometryChange(for: CGFloat.self) { proxy in
                    return proxy.size.height
                } action: { oldValue, newValue in
                    if abs(oldValue - newValue) > 100 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            keyboarHeight = newValue
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .onTapGesture {
            emailFocused = false
            passwordFocused = false
        }
    }
    
    var LoginContentView: some View
    {
        VStack {
            logoView
            
            Text("Welcome back")
                .font(.title2.weight(.semibold))
                .padding(.top, 10)

            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 30)
            
            TextField("Email", text: $email)
                .fontWeight(.bold)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($emailFocused)
                .foregroundStyle(Color.black.opacity(0.6))
                .padding()
                .frame(height: 55)
                .background{
                    Color.blue
                        .opacity(0.4)
                        .cornerRadius(10)
                }
            
            SecureField("Password", text: $password)
                .fontWeight(.bold)
                .focused($passwordFocused)
                .foregroundStyle(Color.black.opacity(0.6))
                .padding()
                .frame(height: 55)
                .background{
                    Color.blue
                        .opacity(0.4)
                        .cornerRadius(10)
                }
            
            HStack {
                Spacer()
                Button {
                    // Forgot password action
                } label: {
                    Text("Forgot password?")
                        .frame(height:44)
                        .fontWeight(.bold)
                }
            }
            
            Button {
                
                emailFocused = false
                passwordFocused = false
            } label: {
                Text("Sign in")
                    .frame(maxWidth:.infinity)
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .padding()
                    .background{
                        Color.blue
                            .cornerRadius(10)
                    }
            }
            .padding(.top,20)
        }
    }
    
    var logoView: some View {
        VStack {
            ZStack {
               Circle()
                   .fill(Color.accentColor.opacity(0.12))
                   .frame(width: 100, height: 100)
               Image(systemName: "person.fill")
                   .font(.system(size: 70, weight: .medium))
                   .foregroundStyle(Color.accentColor)
           }
        }
    }
}

#Preview {
    LoginView2()
}
