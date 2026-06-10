//
//  LoginViewApp.swift
//  LoginView
//
//  Created by Vijendran  on 6/1/26.
//

import SwiftUI

// MARK: - Stretchy Pinned Header
//
// No baseHeight parameter anymore — the header reads its own slot height.
// The slot height is whatever the layout gives it (maxHeight: .infinity).
//
//   minY > 0 (pull down) -> stretches
//   minY < 0 (pan up)    -> compresses, pinned to top

struct StretchyHeader: View {
    let minHeight: CGFloat

    var body: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .scrollView).minY
            let slotHeight = geo.size.height // base height = whatever layout assigned

            Image(.loginScreen) // your asset
                .resizable()
                .scaledToFill()
                .frame(
                    width: geo.size.width,
                    height: max(minHeight, slotHeight + minY)
                )
                .clipped()
                .offset(y: -minY) // pin top edge
        }
    }
}

// MARK: - Login View

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool

    private let minImageHeight: CGFloat = 100

    var body: some View {
        GeometryReader { geo in
            // geo respects the keyboard: when the keyboard appears,
            // geo.size.height SHRINKS by the keyboard height automatically.
            // That shrink flows into the VStack frame -> header slot shrinks
            // -> image compresses. Layout-driven, no scrolling, no offset to reset.
            let contentHeight = geo.size.height + geo.safeAreaInsets.top

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {

                    // Image absorbs ALL space the form doesn't use
                    StretchyHeader(minHeight: minImageHeight)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Form: natural height — no formHeight constant.
                    // Bottom edge is pinned by the fixed VStack height below.
                    formSection
                        .padding(.horizontal, 24)
                        .background(Color.white)
                }
                // Content is EXACTLY the visible height:
                // -> form bottom always lands on the bottom edge (anchored)
                // -> keyboard shrinks contentHeight -> image shrinks
                .frame(height: contentHeight)
                // NOTE: no explicit .animation here.
                // SwiftUI animates keyboard safe-area changes with the system
                // keyboard curve automatically. An explicit eased animation would
                // lag behind the finger during interactive dismissal.
            }
            // Content fits exactly, so allow rubber-band anyway (pan up/down)
            .scrollBounceBehavior(.always, axes: .vertical)
            // Don't tie keyboard dismissal to scrolling — on a real device the
            // mid-drag inset changes make the image resize feel janky.
            .scrollDismissesKeyboard(.never)
            // Dismiss by tapping anywhere outside the text field instead.
            // Child controls (TextField, Buttons) still receive their own taps —
            // this only fires on taps that nothing else claims.
            .onTapGesture {
                emailFocused = false
                passwordFocused = false
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack(spacing: 12) {
                Image(systemName: "square.grid.2x2.fill") // your logo
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.indigo)

                Text("Welcome to KCG Hosptial")
                    .font(.title2.bold())
                    .foregroundStyle(.black)
            }
            .padding(.top, 28)

            VStack(alignment: .leading, spacing: 6) {
                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($emailFocused)
                    .padding(.top, 28)

                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(emailFocused ? .indigo : Color.gray.opacity(0.3))
                    .animation(.easeInOut(duration: 0.2), value: emailFocused)
                
                TextField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($passwordFocused)
                    .padding(.top, 20)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(passwordFocused ? .indigo : Color.gray.opacity(0.3))
                    .animation(.easeInOut(duration: 0.2), value: passwordFocused)
                
            }
            
            HStack{
                Spacer()
                Button {
                    // Implementation
                } label: {
                    Text("Forgot password")
                        .padding()
                        .foregroundStyle(.indigo)
                }.frame(alignment: .trailing)
            }
            .padding(.top,5)
           
            Button {
                // Implementation
            } label: {
                Text("Sign In")
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.indigo)
                    .clipShape(Capsule())
            }
            .padding(.top, 24)
        }
    }
}

#Preview {
    LoginView()
}
